//
//  TripPlannerViewModel.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 24/02/25.
//
import Foundation
import MapKit
import SwiftUI
import WeatherKit
import CloudKit
import Security
import SwiftData

class TripPlannerViewModel: BaseViewModel {
    var modelContext: ModelContext!
    var weatherInfo: String?
    @Binding var selectedTrip: Trip?
    @Published var dates: Set<DateComponents> = []
    @Published var selectedItem: MKMapItem?
    @Published var isBagGenerated: Bool = false
    @Published var showAddressPopover = false
    @Published var selectedTripType: TripType?
    @Published var tripCreatedSuccessfully: Bool = false
    @Published var searchText = ""

    @Published var selectedPlacemark: MKPlacemark?

    init(modelContext: ModelContext, selectedTrip: Binding<Trip?>) {
        self.modelContext = modelContext
        self._selectedTrip = selectedTrip
        super.init()
    }
    
    func fetchWeather(startDate: Date, endDate: Date) async -> String? {
        guard let coordinate = selectedPlacemark?.coordinate else { return "" }
        let weatherService = WeatherService()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        var allForecasts: [DayWeather] = []
        var currentStartDate = startDate
        let calendar = Calendar.current
        
        while currentStartDate <= endDate {
            let currentEndDate = calendar.date(byAdding: .day, value: 9, to: currentStartDate) ?? endDate
            let endDate = min(currentEndDate, endDate)
            
            do {
                let weather = try await weatherService.weather(for: location, including: .daily(startDate: currentStartDate, endDate: endDate))
                allForecasts.append(contentsOf: weather.forecast)
            } catch {
                print("Error fetching weather: \(error)")
                return nil
            }
            
            currentStartDate = calendar.date(byAdding: .day, value: 10, to: currentStartDate) ?? endDate
        }
        
        return "Average high temperature: \(averageHighTemperature(from: allForecasts)) and Average low temperature \(averageLowTemperature(from: allForecasts)), most common condition: \(mostCommonCondition(from: allForecasts))"
    }
    
    func averageHighTemperature(from dayWeathers: [DayWeather]) -> Double {
        let totalTemperature = dayWeathers.reduce(0.0) { (sum, dayWeather) in
            sum + dayWeather.highTemperature.value
        }
        return totalTemperature / Double(dayWeathers.count)
    }
    
    func averageLowTemperature(from dayWeathers: [DayWeather]) -> Double {
        let totalTemperature = dayWeathers.reduce(0.0) { (sum, dayWeather) in
            sum + dayWeather.lowTemperature.value
        }
        return totalTemperature / Double(dayWeathers.count)
    }
    
    func mostCommonCondition(from dayWeathers: [DayWeather]) -> String {
        var conditionCount: [WeatherCondition: Int] = [:]

        for dayWeather in dayWeathers {
            conditionCount[dayWeather.condition, default: 0] += 1
        }

        if let mostCommonCondition = conditionCount.max(by: { $0.value < $1.value })?.key {
            return mostCommonCondition.description
        } else {
            return "No condition data available"
        }
    }

    @MainActor
    func loadBag(aiEnabled: Bool = true) {
        guard let selectedPlacemark = selectedPlacemark else {
            let title = String(localized: "Destination Required")
            let message = String(localized: "Please select a destination before proceeding.")
            showAlert(title: title, message: message)
            return
        }

        guard let startDate = dates.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).first?.date,
              let endDate = dates.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).last?.date else {
            showAlert(title: String(localized: "Dates Required"), message: String(localized: "Please select the dates for your trip before proceeding."))
            return
        }
        
        isLoading = true
        Task {
            do {
                let openAIKey = try await fetchAPIKey()
                weatherInfo = await fetchWeather(startDate: startDate, endDate: endDate)
                print("Weather Info: \(weatherInfo ?? "No weather info")")

                let trip = Trip(
                    destinationName: selectedPlacemark.itemName(),
                    destinationLat: "\(selectedPlacemark.coordinate.latitude)",
                    destinationLong: "\(selectedPlacemark.coordinate.longitude)",
                    startDate: startDate,
                    endDate: endDate,
                    category: selectedTripType?.rawValue.key ?? "General",
                    itemList: []
                )

                let items = try await fetchPackingList(openAIKey: openAIKey, selectedPlacemark: selectedPlacemark, dates: dates, weatherInfo: weatherInfo)

                let sortedItems = items.sorted { (item1, item2) -> Bool in
                    guard let index1 = ItemCategory.allCases.firstIndex(of: item1.category),
                          let index2 = ItemCategory.allCases.firstIndex(of: item2.category) else {
                        return false
                    }
                    return index1 < index2
                }
                sortedItems.forEach { item in
                    item.trip = trip
                }
                trip.itemList = sortedItems

                let database = CKContainer.default().publicCloudDatabase
                try await database.save(trip.toCKRecord())
                
                modelContext.insert(trip)
                isLoading = false
                selectedTrip = trip
            } catch {
                print("Error while generating the bag: \(error)")
//                String(localized: "Error while generating the bag: \(error)")

                isLoading = false
                showAlert(title: "Error while generating the bag", message: "Unable to proceed, please contact support. \nError: \(error)")
            }
        }
    }
    
    func createTrip(selectedPlacemark: MKPlacemark?) {
        guard let selectedPlacemark = selectedPlacemark else {
            let title = String(localized: "Destination Required")
            let message = String(localized: "Please select a destination before proceeding.")
            showAlert(title: title, message: message)
            return
        }

        guard let startDate = dates.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).first?.date,
              let endDate = dates.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).last?.date else {
            showAlert(title: String(localized: "Dates Required"), message: String(localized: "Please select the dates for your trip before proceeding."))
            return
        }
        
        let trip = Trip(
            destinationName: selectedPlacemark.itemName(),
            destinationLat: "\(selectedPlacemark.coordinate.latitude)",
            destinationLong: "\(selectedPlacemark.coordinate.longitude)",
            startDate: startDate,
            endDate: endDate,
            category: selectedTripType?.rawValue.key ?? "General",
            itemList: []
        )
        
        modelContext.insert(trip)
        selectedTrip = trip
    }

    func fetchPackingList(openAIKey: String, selectedPlacemark: MKPlacemark, dates: Set<DateComponents>, weatherInfo: String?) async throws -> [Item] {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var content = "\(selectedPlacemark.title ?? "") for \(dates.count) days"
        
        if let weatherInfo = weatherInfo, !weatherInfo.isEmpty {
            content += " with the weather \(weatherInfo)."
        }
        content += " Could you generate a detailed packing list for my trip?"
        
        if let selectedTripType = selectedTripType {
            content += " I'm going on a \(selectedTripType.rawValue) trip."
        }
        
        let itemImages = ItemImage.allCases.map { $0.rawValue }.joined(separator: ", ")
        let itemCategories = ItemCategory.allCases.map { $0.rawValue }.joined(separator: ", ")
        
        let systemPrompt = """
        You are a helpful assistant that generates a smart packing list for trips using only a carry-on bag. Return a maximum of 32 items from \(itemImages).

        Formatting rules:
        - "name" property must always be translated into \(currentLanguage) and start with an uppercase letter.
        - "tipReason" must always be in \(currentLanguage).
        - "category", "userQuantity", "AIQuantity", "imageName", and "isPair" must always be in English.
        - "AIQuantity" must match "userQuantity" and reflect the appropriate number of each item to pack.
        - "tipReason" should be a single sentence explaining the recommended quantity. Example: If suggesting 7 tops for a 14-day trip, mention that laundry is available in most hotels.

        Image handling:
        - "imageName" should match a predefined name from \(itemImages), if applicable.
        - If no match is found, use an appropriate SF Symbol.

        Categorization:
        - "category" must be one of the predefined values in \(itemCategories). DO NOT modify or translate these values. Always return them exactly as they appear in \(itemCategories).

        Response constraints:
        - Do not exceed 15,000 characters.
        - Return a JSON array in the following format:

        [
          {
            "name": "", // Ensure this is translated into \(currentLanguage) and capitalized.
            "category": "",
            "userQuantity": 1,
            "AIQuantity": 1,
            "imageName": "",
            "isPair": false,
            "tipReason": ""
          }
        ]
        """


        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": content]
            ],
            "n": 1,
            "max_tokens": 4000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print("\nRESULT: \n\(String(decoding: jsonData, as: UTF8.self))\n")
        }
        
        if var jsonString = String(data: data, encoding: .utf8) {
            jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if jsonString.contains("```json") {
                jsonString = jsonString.replacingOccurrences(of: "```json", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if jsonString.contains("```") {
                jsonString = jsonString.replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }

            if let jsonData = jsonString.data(using: .utf8) {
                let response = try JSONDecoder().decode(ChatGPTResponse.self, from: jsonData)
                return response.items
            }
        }
        
        let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
        return response.items
    }

    func fetchAPIKey() async throws -> String {
        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "APIKey", predicate: predicate)

        let (records, _) = try await database.records(matching: query, resultsLimit: 1)
        let key = try records.compactMap { (id, record) -> APIKey? in
            APIKey.ckRecord(from: try record.get())
        }.first?.key ?? ""
        
        if key.isEmpty {
            throw NSError(domain: "com.wecansave", code: 1, userInfo: [NSLocalizedDescriptionKey: "API key not found"])
        }
        return key
    }
    
    func saveAPIKeyToKeychain(_ key: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIAPIKey",
            kSecValueData as String: key.data(using: .utf8)!
        ]

        SecItemDelete(keychainQuery as CFDictionary)
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)

        if status == errSecSuccess {
            print("API key saved to Keychain successfully.")
        } else {
            print("Failed to save API key to Keychain: \(status)")
        }
    }
    
    func getAPIKeyFromKeychain() -> String {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAIAPIKey",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8) ?? ""
            }
        } else {
            print("Failed to retrieve API key from Keychain: \(status)")
        }
        return ""
    }
}
