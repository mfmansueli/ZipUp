//
//  TripPlannerViewModel.swift
//  WeCanSave
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
    var searchTimer: Timer?
    @Published var selectedTrip: Trip?
    @Published var searchText = "" {
        didSet {
            searchTimer?.invalidate()
            if !searchText.isEmpty {
                searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                    self?.searchDestinations()
                }
            }
        }
    }
    @Published var dates: Set<DateComponents> = []
    @Published var searchResults: [MKMapItem] = []
    @Published var selectedItem: MKMapItem?
    @Published var isBagGenerated: Bool = false
    @Published var items = [Item]()
    @Published var showAddressPopover = false
    @Published var selectedPlacemark: MKPlacemark?
    @Published var selectedTripType: TripType?
    var weatherInfo: String?

    override init() {
        super.init()
        if getAPIKeyFromKeychain() == nil {
            fetchAPIKey()
        }
    }
    
    func searchDestinations() {
        searchTimer?.invalidate()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.resultTypes = [.address, .pointOfInterest]
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            self?.searchResults = response.mapItems
            self?.showAddressPopover = true
            self?.printSearchResults()
        }
    }

    func printSearchResults() {
        for item in searchResults {
            print("Name: \(item.name ?? "No name")")
            print("Phone: \(item.phoneNumber ?? "No phone number")")
            print("URL: \(item.url?.absoluteString ?? "No URL")")

            print("Address: \(item.placemark.thoroughfare ?? "No address"), \(item.placemark.locality ?? "No city"), \(item.placemark.administrativeArea ?? "No state"), \(item.placemark.postalCode ?? "No postal code"), \(item.placemark.country ?? "No country")")
            print("Latitude: \(item.placemark.coordinate.latitude)")
            print("Longitude: \(item.placemark.coordinate.longitude)")
            print("-----")
        }
    }

    func fetchWeather() async throws -> String {
        guard let coordinate = selectedPlacemark?.coordinate else { return "" }
        let weatherService = WeatherService()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let weather = try await weatherService.weather(for: location)
        return "Temperature: \(weather.currentWeather.temperature), Condition: \(weather.currentWeather.condition.description)"
    }
    

    @MainActor
    func loadBag(aiEnabled: Bool = true) {
        guard let selectedPlacemark = selectedPlacemark else {
            showAlert(title: "Destination Required", message: "Please select a destination before proceeding.")
            return
        }

        guard let firstDate = dates.first?.date,
              let lastDate = dates.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).last?.date else {
            showAlert(title: "Dates Required", message: "Please select the dates for your trip before proceeding.")
            return
        }

        guard let openAIKey = getAPIKeyFromKeychain() else {
            showAlert(title: "Error while generating the bag", message: "Unable to proceed, please contact support.")
            return
        }
        
        isLoading = true
        Task {
            do {
                weatherInfo = try await fetchWeather()
                items = try await fetchPackingList(openAIKey: openAIKey, selectedPlacemark: selectedPlacemark, dates: dates, weatherInfo: weatherInfo)
                let trip = Trip(
                    destinationName: selectedPlacemark.title ?? "Unknown Destination",
                    destinationLat: "\(selectedPlacemark.coordinate.latitude)",
                    destinationLong: "\(selectedPlacemark.coordinate.longitude)",
                    startDate: firstDate,
                    endDate: lastDate,
                    category: selectedTripType?.rawValue ?? "General",
                    bag: Bag(itemList: items)
                )
                modelContext.insert(trip)

                let database = CKContainer.default().publicCloudDatabase
                try await database.save(trip.toCKRecord())

                isLoading = false
                selectedTrip = trip
            } catch {
                isLoading = false
                showAlert(title: "Error while generating the bag", message: "Unable to proceed, please contact support. \nError: \(error)")
            }
        }
    }

    func fetchPackingList(openAIKey: String, selectedPlacemark: MKPlacemark, dates: Set<DateComponents>, weatherInfo: String?) async throws -> [Item] {
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var content = "\(selectedPlacemark.title ?? "") for \(dates.count) days"

        if let weatherInfo = weatherInfo, !weatherInfo.isEmpty {
            content += " with the weather \(weatherInfo)"
        }
        content += " could you give me a list of things to bring to my trip?"
        if let selectedTripType = selectedTripType {
            content += "I'm going on a \(selectedTripType.rawValue) trip."
        }
        content += "Please respond in \(currentLanguage)."
        
        let parameters = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that generates fresh and unique insights about my packing list for a trip. Always respond in json format. Return the at least 20 or more items in the format inside a list: {\"name\": \"item name\", \"category\": \"category name\", \"userQuantity\": 1, \"AIQuantity\": 1, \"imageName\": \"image name\", \"isPair\": false}"
                ],
                [
                    "role": "user",
                    "content": content
                ]
            ],
            "n": 1,
            "max_tokens": 4000
        ] as [String : Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print("\nRESULT: \n\(String(decoding: jsonData, as: UTF8.self))\n")
        }

        let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
        return response.items
    }


    func fetchAPIKey() {
        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "APIKey", predicate: predicate)

        database.fetch(withQuery: query, resultsLimit: 1) { [weak self] result in
            switch result {
            case .success(let (records, _)):
                do {
                    let key = try records.compactMap { (id, record) -> APIKey? in
                        APIKey.ckRecord(from: try record.get())
                    }.first?.key ?? ""
                    
                    self?.saveAPIKeyToKeychain(key)
                } catch {
                    print("Failed to fetch API key: \(error)")
                }
            case .failure(let error):
                print("Failed to fetch API key: \(error)")
            }
        }
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
    
    func getAPIKeyFromKeychain() -> String? {
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
                return String(data: data, encoding: .utf8)
            }
        } else {
            print("Failed to retrieve API key from Keychain: \(status)")
        }
        return nil
    }
}
