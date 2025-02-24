//
//  TripPlannerView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//
import SwiftUI
import MapKit

struct TripPlannerView: View {
    @ObservedObject var viewModel = TripPlannerViewModel()

    var body: some View {
        VStack {
            TextField("Search for an address", text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            List(viewModel.searchResults, id: \.self) { item in
                Button(action: {
                    viewModel.selectedItem = item
                    viewModel.fetchWeather(for: item.placemark.coordinate)
                }) {
                    Text(item.placemark.title ?? "")
                }
            }

            if let weatherInfo = viewModel.weatherInfo {
                Text(weatherInfo)
                    .padding()
            }
        }
    }
}

#Preview {
    TripPlannerView()
}
