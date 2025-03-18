//
//  WeatherViewModel.swift
//  WeCanSave
//
//  Created by Lehebel Florence on 11/03/25.
//

import Foundation
import WeatherKit
import Combine
import Foundation
import CoreLocation

class WeatherViewModel: ObservableObject {
    @Published var allForecasts: [DayWeather] = []
    @Published var isLoading = false
    @Published var averageHighTemperature: String = ""
    @Published var averageLowTemperature: String = ""
    @Published var mostCommonCondition: (condition: WeatherCondition?, imageName: String?) = (nil, nil)
    var isSuccessfulLoaded = false
    private var cancellables = Set<AnyCancellable>()
    
    func fetchWeather(lat: Double, long: Double, startDate: Date, endDate: Date) -> AnyPublisher<[DayWeather], Error> {
        Future { promise in
            Task {
                do {
                    let location = CLLocation(latitude: lat, longitude: long)
                    var allForecasts: [DayWeather] = []
                    let calendar = Calendar.current
                    let today = Date()
                    var currentStartDate = calendar.dateComponents([.day], from: today, to: endDate).day ?? 0 > 10
                        ? calendar.date(byAdding: .year, value: -1, to: startDate) ?? startDate
                        : startDate
                    let adjustedEndDate = calendar.dateComponents([.day], from: today, to: endDate).day ?? 0 > 10
                        ? calendar.date(byAdding: .year, value: -1, to: endDate) ?? endDate
                        : endDate

                    while currentStartDate <= adjustedEndDate {
                        let currentEndDate = min(calendar.date(byAdding: .day, value: 9, to: currentStartDate) ?? adjustedEndDate, adjustedEndDate)
                        let weather = try await WeatherService().weather(for: location, including: .daily(startDate: currentStartDate, endDate: currentEndDate))
                        allForecasts.append(contentsOf: weather.forecast)
                        currentStartDate = calendar.date(byAdding: .day, value: 10, to: currentStartDate) ?? adjustedEndDate
                    }

                    promise(.success(allForecasts))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    init(trip: Trip) {
        if !isSuccessfulLoaded, let lat = Double(trip.destinationLat),
           let long = Double(trip.destinationLong) {
            isLoading = true
            fetchWeather(lat: lat, long: long, startDate: trip.startDate, endDate: trip.endDate)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Failed to fetch weather: \(error)")
                    }
                }, receiveValue: { [weak self] forecasts in
                    self?.isSuccessfulLoaded = true
                    self?.allForecasts = forecasts
                    self?.averageHighTemperature = self?.calculateAverageHighTemperature() ?? ""
                    self?.averageLowTemperature = self?.calculateAverageLowTemperature() ?? ""
                    self?.mostCommonCondition = self?.calculateMostCommonCondition() ?? (nil, nil)
                })
                .store(in: &cancellables)
        }
    }
    
    func calculateAverageHighTemperature() -> String {
        let totalTemperature = allForecasts.reduce(0.0) { (sum, dayWeather) in
            sum + dayWeather.highTemperature.value
        }
        let max = totalTemperature / Double(allForecasts.count)
        
        return String(format: "%.1f", max) + "°C"
    }
    
    func calculateAverageLowTemperature() -> String {
        let totalTemperature = allForecasts.reduce(0.0) { (sum, dayWeather) in
            sum + dayWeather.lowTemperature.value
        }
        let min = totalTemperature / Double (allForecasts.count)
        
        return String(format: "%.1f", min) + "°C"
    }
    
    func calculateMostCommonCondition() -> (condition: WeatherCondition?, imageName: String?) {
        var conditionCount: [WeatherCondition: Int] = [:]
        var conditionImage: [String: Int] = [:]
        
        for dayWeather in allForecasts {
            
            
            conditionImage[dayWeather.symbolName, default: 0] += 1
            conditionCount[dayWeather.condition, default: 0] += 1
        }
        
        let mostCommonCondition = conditionCount.max(by: { $0.value < $1.value })?.key
        
        let mostCommonImage = conditionImage.max(by: { $0.value < $1.value })?.key
        
        return (mostCommonCondition, mostCommonImage)
    }
}
