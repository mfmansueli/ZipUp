//
//  DestinationViewModel.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 21/03/25.
//

import Foundation
import MapKit

class DestinationViewModel: ObservableObject {
    @Published var searchText = "" {
        didSet {
            searchTimer?.invalidate()
            if searchText.isEmpty {
                searchResults = []
            } else if searchText != selectedPlacemark?.title {
                searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                    self?.searchDestinations()
                }
            }
        }
    }
    
    @Published var selectedPlacemark: MKPlacemark? {
        didSet {
            if let title = selectedPlacemark?.title, !title.isEmpty {
                searchText = title
                searchTimer?.invalidate()
                searchResults = []
            }
        }
    }
    @Published var searchResults: [MKMapItem] = []
    @Published var isLoading: Bool = false
    var searchTimer: Timer?
    
    func searchDestinations() {
        isLoading = true
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
            defer {
                self?.isLoading = false
            }
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var uniqueLocations = Set<String>()
            var filteredResults = [MKMapItem]()
            
            for item in response.mapItems {
                let locality = item.placemark.locality ?? ""
                let state = item.placemark.administrativeArea ?? ""
                let country = item.placemark.country ?? ""
                let locationKey = "\(locality),\(state),\(country)"
                
                if !uniqueLocations.contains(locationKey) {
                    uniqueLocations.insert(locationKey)
                    filteredResults.append(item)
                }
            }
            
            self?.searchResults = filteredResults
        }
    }
}
