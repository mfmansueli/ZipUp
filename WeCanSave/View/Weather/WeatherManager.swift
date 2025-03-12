//
//  WeatherManager.swift
//  WeCanSave
//
//  Created by Lehebel Florence on 11/03/25.
//

import Foundation
import WeatherKit

@Observable class WeatherManager {
    private let weatherService = WeatherService()
    
    var weather: Weather?
    
    //Average Max Temp
    var averageMaxTemperature: String {
        guard let forecast = weather?.dailyForecast else { return "--" }
        let maxTemps = forecast.map { $0.highTemperature.converted(to: .celsius).value }
        let average = maxTemps.reduce(0, +) / Double(maxTemps.count)
        return String(Int(round(average))) + "°"
    }
    //Average Min Temp
    var averageMinTemperature: String {
        guard let forecast = weather?.dailyForecast else { return "--" }
        let minTemps = forecast.map { $0.lowTemperature.converted(to: .celsius).value }
        let average = minTemps.reduce(0, +) / Double(minTemps.count)
        return String(Int(round(average))) + "°"
    }
    //Icon for the weather
    var averageWeatherCondition: (icon: String, description: String) {
        guard let forecast = weather?.dailyForecast else {
            return ("cloud", "Unknown")
        }
    
        var conditionCounts: [String: (count: Int, description: String)] = [:]
        
        for day in forecast {
            let symbol = day.symbolName
            // Create more descriptive conditions based on the symbol
            let description = getWeatherDescription(for: symbol)
            if let existing = conditionCounts[symbol] {
                conditionCounts[symbol] = (existing.count + 1, description)
            } else {
                conditionCounts[symbol] = (1, description)
            }
        }
        
        // Find most common condition
        let mostCommon = conditionCounts.max(by: { $0.value.count < $1.value.count })
        return (mostCommon?.key ?? "cloud", mostCommon?.value.description ?? "Mostly cloudy")
    }
    
    private func getWeatherDescription(for symbol: String) -> String {
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
        
    func getWeather(lat: Double, long: Double) async {
        do {
            weather = try await Task.detached(priority: .userInitiated) { [weak self] in
                return try await self?.weatherService.weather(for: .init(latitude: lat, longitude: long))
            }.value
        } catch {
            print("Failed to get weather data.\(error) ")
        }
    }
    
    // Add daily forecast data structure
    struct DailyForecast {
        let date: Date
        let maxTemp: String
        let minTemp: String
        let icon: String
        let description: String
    }
    
    // Add computed property for daily forecasts
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
    
//    var icon: String {
//        guard let iconName = weather?.currentWeather.symbolName else { return "--"}
//        return iconName
//    }
//    var temperature: String {
//        guard let temp = weather?.currentWeather.temperature else { return "--"}
//        let convert = temp.converted(to: .celsius).value
//        
//        return String(Int(convert)) + "°C"
//        
//    }
}
