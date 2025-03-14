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
    @State private var weatherManager: WeatherManager
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
        self.weatherManager = WeatherManager(trip: trip)
        self.trip = trip
    }
    
    var body: some View {
        Button(action: { isExpanded.toggle() }) {
            ZStack {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Text(trip.destinationName)
                                .font(.largeTitle)
                                .foregroundColor(.black)
                                .bold()
                            
                            HStack {
                                //Number of days
                                Text("\(trip.duration) Days")
                                    .font(.body)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.down.circle")
                                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                                    .animation(.easeInOut, value: isExpanded)
                            }
                            
                            .popover(isPresented: $isExpanded) {
                                forecastList
                            }
                        }
                        
                        //averageMaxTemp
                        HStack(spacing: 4) {
                            Text(weatherManager.averageHighTemperature()) // Update this line
                                .font(.title)
                                .foregroundColor(.black)
                            
                            Text("avg. max.")
                                .font(.body)
                                .foregroundColor(.black)
                            
                        }
                        
                        //averageMinTemp
                        HStack(spacing: 4) {
                            Text(weatherManager.averageLowTemperature())
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("avg. min.")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Image(systemName: weatherManager.mostCommonCondition().imageName ?? "")
                            .font(.system(size: 80))
                            .foregroundColor(.black)
                        
                        Text(weatherManager.averageWeatherCondition.description)
                            .font(.body)
                            .foregroundColor(.black)
                        
                        
                    }
                    .padding(.horizontal, 15)
                }
//                .onAppear {
//                }
            }
        }
    }
    
    var forecastList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(weatherManager.dailyForecasts, id: \.date) { forecast in
                    VStack {
                        HStack {
                            // Date
                            Text(dateFormatter.string(from: forecast.date))
                                .frame(width: 160, alignment: .leading)
                                .font(.system(.body, weight: .medium))
                            
                            // Weather icon
                            Image(systemName: forecast.icon)
                                .symbolRenderingMode(.multicolor)
                                .font(.title2)
                                .frame(width: 40)
                            
                            // Max temperature
                            Text(forecast.maxTemp)
                                .frame(width: 40)
                                .fontWeight(.medium)
                            
                            // Min temperature
                            Text(forecast.minTemp)
                                .frame(width: 40)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        
                        Divider()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .foregroundColor(.black)
        
        .presentationCompactAdaptation(.popover)
        .padding(.vertical)
    }
}

#Preview {
    WeatherView(trip: Trip.exampleTrip)
}
