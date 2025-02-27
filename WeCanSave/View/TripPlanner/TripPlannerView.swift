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
            Divider()
            TextField("Search for an address", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .padding(.all, 8)
                .background(Color.primary)
                .cornerRadius(8)
                .foregroundStyle(Color(uiColor: .systemBackground))
                .textFieldStyle(.roundedBorder)

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
