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
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("\(shortDateString(startDate: trip.startDate, endDate: trip.endDate))")
                        .font(.callout)
                        .fontWeight(.thin)
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down.circle")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut, value: isExpanded)
                    
                }
                
                HStack(alignment: .bottom) {
                    
                    
                    HStack(spacing: 4) {
                        VStack(alignment: .trailing, spacing: 8) {
                            
                            //averageMaxTemp
                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text(viewmodel.averageHighTemperature) // Update this line
                                    .font(.title)
                                    .minimumScaleFactor(0.01)
                                    .foregroundColor(.primary)
                                

                                
                                Text("avg. max.")
                                    .font(.body)
                                    .frame(width: 80)
                                    .minimumScaleFactor(0.01)
                                    .foregroundColor(.primary)
                                
                            }
                            
                            //averageMinTemp
                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text(viewmodel.averageLowTemperature)
                                    .font(.title)
                                    .minimumScaleFactor(0.01)
                                    .foregroundColor(.secondary)
                                

                                Text("avg. min.")
                                    .font(.body)
                                    .frame(width: 80)
                                    .minimumScaleFactor(0.01)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()

                    
                    VStack(spacing: 8) {
                        Image(systemName: viewmodel.mostCommonCondition.imageName ?? "cloud.sun")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.primary)
                            .frame(minWidth: 40, maxWidth: 60)
                        
                        Text(viewmodel.mostCommonCondition.condition?.description ?? "Mostly sunny")
                            .lineLimit(1)
                            .minimumScaleFactor(0.01)
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                    }
                }.layoutPriority(1)
                
                
            }
            .padding(.horizontal, 5)
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
    
    func shortDateString(startDate: Date, endDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM")
        
        let beginning = dateFormatter.string(from: startDate)
        let end = dateFormatter.string(from: endDate)
        
        return "\(beginning)–\(end)"
    }
}

#Preview {
    WeatherView(trip: Trip.exampleTrip)
}

#Preview {
    BagBuilderView(trip: Trip.exampleTrip)
}
