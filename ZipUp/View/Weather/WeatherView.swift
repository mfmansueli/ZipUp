//
//  WeatherView.swift
//  ZipUp
//
//  Created by Lehebel Florence on 10/03/25.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherView: View {
    @StateObject private var viewmodel: WeatherViewModel
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
        _viewmodel = StateObject(wrappedValue: WeatherViewModel(trip: trip))
        self.trip = trip
    }
    
    var body: some View {
        Button(action: {
            if !viewmodel.allForecasts.isEmpty {
                isExpanded.toggle()
            }
        }) {
            
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
                    VStack(alignment: .trailing, spacing: 8) {
                        
                        //MARK: Average max temp
                        HStack(alignment: .center, spacing: 5) {
                            Text(viewmodel.averageHighTemperature)
                                .font(.title)
                                .minimumScaleFactor(0.01)
                                .foregroundColor(.primary)
                            
                            Text("avg. max.")
                                .font(.body)
                                .minimumScaleFactor(0.01)
                                .foregroundColor(.primary)
                        }
                        
                        //MARK: Average min temp
                        HStack(alignment: .center, spacing: 5) {
                            Text(viewmodel.averageLowTemperature)
                                .font(.title)
                                .minimumScaleFactor(0.01)
                                .foregroundColor(.secondary)
                            
                            Text("avg. min.")
                                .font(.body)
                                .minimumScaleFactor(0.01)
                                .foregroundColor(.secondary)
                        }
                    }
                    .layoutPriority(1)
                    
                    VStack(spacing: 8) {
                        Image(systemName: viewmodel.mostCommonCondition.imageName ?? "cloud.sun")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.primary)
                            .frame(minWidth: 50, maxWidth: 70)
                            .layoutPriority(0)
                        
                        Text(viewmodel.mostCommonCondition.condition?.description ?? "Mostly sunny")
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.01)
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                    }
                    .layoutPriority(0)
                    .padding(.leading, 16)
                    .popover(isPresented: $isExpanded) {
                        forecastList
                    }
                    
                    Spacer()
                }.layoutPriority(1)
            }
            .padding(.horizontal, 5)
        }
    }
    
    var forecastList: some View {
        ScrollView {
            VStack(spacing: 8) {
                
                Text(viewmodel.noteMessage)
                    .font(.footnote)
                    
                    
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
    BagBuilderView(trip: ObservedObject(initialValue: Trip.exampleTrip))
}
