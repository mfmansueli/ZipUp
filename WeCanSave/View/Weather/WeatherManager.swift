//
//  WeatherManager.swift
//  WeCanSave
//
//  Created by Lehebel Florence on 11/03/25.
//

import Foundation
import WeatherKit
import CoreLocation

@Observable class WeatherManager {
    private let weatherService = WeatherService()
    
    var weather: Weather?
    var allForecasts: [DayWeather] = []
    
    func fetchWeather(lat: Double, long: Double, startDate: Date, endDate: Date) async throws -> [DayWeather] {
        
        let location = CLLocation(latitude: lat, longitude: long)
        
        var allForecasts: [DayWeather] = []
        var currentStartDate = startDate
        let calendar = Calendar.current
        
        while currentStartDate <= endDate {
            let currentEndDate = calendar.date(byAdding: .day, value: 9, to: currentStartDate) ?? endDate
            let endDate = min(currentEndDate, endDate)
            let weather = try await weatherService.weather(for: location, including: .daily(startDate: currentStartDate, endDate: endDate))
            allForecasts.append(contentsOf: weather.forecast)
            
            currentStartDate = calendar.date(byAdding: .day, value: 10, to: currentStartDate) ?? endDate
        }
        
        return allForecasts
    }
    
    init(trip: Trip) {
        Task {
            do {
                if let lat = Double(trip.destinationLat),
                   let long = Double(trip.destinationLong) {
                    allForecasts = try await fetchWeather(
                        lat: lat,
                        long: long,
                        startDate: trip.startDate,
                        endDate: trip.endDate
                    )
                }
            } catch {
                print("Failed to fetch weather: \(error)")
            }
        }
    }
    
    func averageHighTemperature() -> String {
        let totalTemperature = allForecasts.reduce(0.0) { (sum, dayWeather) in
            sum + dayWeather.highTemperature.value
        }
        let max = totalTemperature / Double(allForecasts.count)
        
        return String(format: "%.1f", max) + "°C"
    }
    
    func averageLowTemperature() -> String {
        let totalTemperature = allForecasts.reduce(0.0) { (sum, dayWeather) in
            sum + dayWeather.lowTemperature.value
        }
        let min = totalTemperature / Double (allForecasts.count)
        
        return String(format: "%.1f", min) + "°C"
    }
    
    func mostCommonCondition() -> (condition: WeatherCondition?, imageName: String?) {
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
    
    
    // Main weather fetch function
    func getWeather(lat: Double, long: Double) async {
        do {
            self.weather = try await Task.detached(priority: .userInitiated) { [weak self] in
                let result = try await self?.weatherService.weather(for: .init(latitude: lat, longitude: long))
                return result
            }.value
        } catch {
            print("Failed to get weather data.\(error) ")
        }
    }
    
    // Daily forecast data structure
    struct DailyForecast {
        let date: Date
        let maxTemp: String
        let minTemp: String
        let icon: String
        let description: String
    }
    
    // Properties for current weather display
    var averageMaxTemperature: String {
        guard let forecast = weather?.dailyForecast else { return "--" }
        let maxTemps = forecast.map { $0.highTemperature.converted(to: .celsius).value }
        let average = maxTemps.reduce(0, +) / Double(maxTemps.count)
        return String(Int(round(average))) + "°"
    }
    
    var averageMinTemperature: String {
        guard let forecast = weather?.dailyForecast else { return "--" }
        let minTemps = forecast.map { $0.lowTemperature.converted(to: .celsius).value }
        let average = minTemps.reduce(0, +) / Double(minTemps.count)
        return String(Int(round(average))) + "°"
    }
    
    var averageWeatherCondition: (icon: String, description: String) {
        guard let forecast = weather?.dailyForecast else {
            return ("cloud", "Unknown")
        }
        
        var conditionCounts: [String: (count: Int, description: String)] = [:]
        
        for day in forecast {
            let symbol = day.symbolName
            let description = getWeatherDescription(for: symbol)
            if let existing = conditionCounts[symbol] {
                conditionCounts[symbol] = (existing.count + 1, description)
            } else {
                conditionCounts[symbol] = (1, description)
            }
        }
        
        let mostCommon = conditionCounts.max(by: { $0.value.count < $1.value.count })
        return (mostCommon?.key ?? "cloud", mostCommon?.value.description ?? "Mostly cloudy")
    }
    
    // Computed property for daily forecasts
    var dailyForecasts: [DailyForecast] {
        guard let forecast = weather?.dailyForecast else { return [] }
        
        return Array(forecast.prefix(10)).map { day in
            DailyForecast(
                date: day.date,
                maxTemp: String(Int(round(day.highTemperature.converted(to: .celsius).value))) + "°",
                minTemp: String(Int(round(day.lowTemperature.converted(to: .celsius).value))) + "°",
                icon: day.symbolName,
                description: getWeatherDescription(for: day.symbolName)
            )
        }
    }
    
    // Helper function for weather descriptions
    func getWeatherDescription(for symbol: String) -> String {
        switch symbol {
        case let s where s.contains("sun") || s.contains("clear"):
            return "Sunny"
        case let s where s.contains("cloud") && s.contains("sun"):
            return "Partly Cloudy"
        case let s where s.contains("cloud"):
            return "Cloudy"
        case let s where s.contains("rain"):
            return "Rainy"
        case let s where s.contains("snow"):
            return "Snowy"
        case let s where s.contains("wind"):
            return "Windy"
        case let s where s.contains("fog"):
            return "Foggy"
        default:
            return "Mixed Weather"
        }
    }
}

