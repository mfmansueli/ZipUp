//
//  TripPlannerViewModel.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//
import Foundation
import MapKit
import WeatherKit

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
}
