//
//  TripPlannerViewModel.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//
import Foundation
import MapKit
@preconcurrency import WeatherKit
import CloudKit
import Security


class TripPlannerViewModel: ObservableObject {
    var searchTimer: Timer?
    @Published var searchText = "" {
        didSet {
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.searchDestinations()
            }
        }
    }
    @Published var searchResults: [MKMapItem] = []
    @Published var weatherInfo: String?
    @Published var selectedItem: MKMapItem?
    @Published var isLoading: Bool = false
    @Published var isBagGenerated: Bool = false
    @Published var items = [Item]()

    init() {
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

    func fetchWeather(for coordinate: CLLocationCoordinate2D) {
        let weatherService = WeatherService()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                DispatchQueue.main.async { [weak self] in
                    self?.weatherInfo = "Temperature: \(weather.currentWeather.temperature)°C, Condition: \(weather.currentWeather.condition.description)"
                    print(self?.weatherInfo ?? "")
                }
            } catch {
                print("Failed to fetch weather: \(error.localizedDescription)")
            }
        }
    }
    
    func loadBag(aiEnabled: Bool = true) {
        guard let openAIKey = getAPIKeyFromKeychain() else {
            print("No API key found.")
            return
        }
        
        let currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let temperature = 0.7
        let top_p = 0.9
        
        let parameters = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that generates fresh and unique insights about your packing list for a trip. Always respond in json format. Return the items in the format inside a list: {\"name\": \"item name\", \"category\": \"category name\", \"quantity\": 1, \"AIQuantity\": 1, \"imageName\": \"image name\", \"isPair\": false}"
                ],
                [
                    "role": "user",
                    "content": "Venice for 3 days in summer could you give me a list of things to bring to my trip? Please respond in \(currentLanguage)."
                ]
            ],
            "temperature": temperature,
            "top_p": top_p,
            "n": 1,
            "max_tokens": 3000
        ] as [String : Any]
        
        do {
            isLoading = true
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let data = data else { return }
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    print("\nRESULT: \n\(String(decoding: jsonData, as: UTF8.self))\n")
                }
                do {
                    let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
                    let items = response.items
                    print(items)
                    
                    self?.isBagGenerated = true
                } catch {
                    print("Failed to decode bag: \(error.localizedDescription)")
                }
            }.resume()
        } catch {
            print("Failed to encode parameters: \(error.localizedDescription)")
        }
    }
    
    func fetchAPIKey() {
        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "APIKey", predicate: predicate)

        database.fetch(withQuery: query, resultsLimit: 1) { [weak self] result in
            switch result {
            case .success(let (records, cursor)):
                do {
                    let key = try records.compactMap { (id, record) -> APIKey? in
                        APIKey.ckRecord(from: try record.get())
                    }.first?.key ?? ""
                    
                    self?.saveAPIKeyToKeychain(key)
                } catch {
                    print("Failed to fetch API key: \(error)")
                    let test = ""
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
