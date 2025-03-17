//
//  WeatherView.swift
//  WeCanSave
//
//  Created by Lehebel Florence on 10/03/25.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherView: View {
    @ObservedObject private var viewmodel: WeatherViewModel
    @State private var isExpanded = false // Add state for expansion
    var trip: Trip
    
    
    // Custom date formatter for forecast dates
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    init(trip: Trip) {
        self.viewmodel = WeatherViewModel(trip: trip)
        self.trip = trip
    }
    
    var body: some View {
        Button(action: { isExpanded.toggle() }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack{
                        Text(trip.destinationName)
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                            .bold()
                        
                        HStack {
                            //Number of days
                            Text("\(trip.duration) Days")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Image(systemName: "chevron.down.circle")
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                .animation(.easeInOut, value: isExpanded)
                        }
                    }
                    
                    //averageMaxTemp
                    HStack(spacing: 4) {
                        Text(viewmodel.averageHighTemperature) // Update this line
                            .font(.title)
                            .foregroundColor(.primary)
                        
                        Text("avg. max.")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                    }
                    
                    //averageMinTemp
                    HStack(spacing: 4) {
                        Text(viewmodel.averageLowTemperature)
                            .font(.title)
                            .foregroundColor(.secondary)
                        
                        Text("avg. min.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: viewmodel.mostCommonCondition.imageName ?? "")
                        .font(.system(size: 80))
                        .foregroundColor(.primary)
                    
                    Text(viewmodel.mostCommonCondition.condition?.description ?? "")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 15)
            }
        }
        .popover(isPresented: $isExpanded) {
            forecastList
        }
    }
    
    var forecastList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(viewmodel.allForecasts, id: \.date) { (forecast: DayWeather) in
                    VStack {
                        HStack {
                            // Date
                            Text(dateFormatter.string(from: forecast.date))
                                .frame(width: 160, alignment: .leading)
                                .font(.system(.body, weight: .medium))
                            
                            // Weather icon
                            Image(systemName: forecast.symbolName)
                                .symbolRenderingMode(.multicolor)
                                .font(.title2)
                                .frame(width: 40)
                            
                            // Max temperature
                            Text(formattedTemperature(temperature: forecast.highTemperature))
                                .frame(width: 40)
                                .fontWeight(.medium)
                            
                            // Min temperature
                            Text(formattedTemperature(temperature: forecast.lowTemperature))
                                .frame(width: 40)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        
                        Divider()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .foregroundColor(.primary)
        .presentationCompactAdaptation(.popover)
        .padding(.vertical)
    }
    
    func formattedTemperature(temperature: Measurement<UnitTemperature>) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter.string(from: temperature)
    }
    
}

#Preview {
    WeatherView(trip: Trip.exampleTrip)
}
