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
    @State private var weatherManager = WeatherManager()
    @State private var isExpanded = false // Add state for expansion
    
    var trip: Trip
    var latitude: Double { Double(trip.destinationLat) ?? 0.0 }
    var longitude: Double { Double(trip.destinationLong) ?? 0.0 }
    
    // Add date formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    //    let paris = CLLocation(latitude: 48.8566, longitude: 2.3522)
    
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
                            //                        Text("\(weatherManager.temperature)")
                            //                        Button(action: { isExpanded.toggle() }) {
                            HStack {
                                //Number of days
                                Text("\(trip.duration) Days")
                                    .font(.body)
                                    .foregroundColor(.black)

                                Image(systemName: "chevron.down.circle")
                                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                                    .animation(.easeInOut, value: isExpanded)
                            }
                            //                        }
                            //Start and End date
                            //                        VStack(alignment: .leading) {
                            //                            Text(dateFormatter.string(from: trip.startDate))
                            //                            Text(dateFormatter.string(from: trip.endDate))
                            //                        }
                            //                        .font(.caption)
                            .popover(isPresented: $isExpanded) {
                                
                                VStack(spacing: 15) {
                                    ForEach(weatherManager.dailyForecasts, id: \.date) { forecast in
                                        HStack {
                                            Text(forecast.date, style: .date)
                                                .frame(width: 100, alignment: .leading)
                                            
                                            Text(forecast.maxTemp)
                                                .frame(width: 50)
                                            
                                            Text(forecast.minTemp)
                                                .foregroundColor(.gray)
                                                .frame(width: 50)
                                            Image(systemName: forecast.icon)
                                                .frame(width: 30)
                                            Text(forecast.description)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .foregroundColor(.black)
                                
                                    .presentationCompactAdaptation(.popover)
                                .padding(.vertical)
                            }
                        }
                        
                        //averageMaxTemp
                        HStack(spacing: 4) {
                            Text(weatherManager.averageMaxTemperature) // Update this line
                                .font(.title)
                                .foregroundColor(.black)

                            Text("avg. max.")
                                .font(.body)
                                .foregroundColor(.black)

                        }
                        
                        //averageMinTemp
                        HStack(spacing: 4) {
                            Text(weatherManager.averageMinTemperature)
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
                        Image(systemName: weatherManager.averageWeatherCondition.icon)
                            .font(.system(size: 80))
                            .foregroundColor(.black)

                        Text(weatherManager.averageWeatherCondition.description)
                            .font(.body)
                            .foregroundColor(.black)

                        
                    }
                    .padding(.horizontal, 15)
                }
                .onAppear {
                    Task {
                        await weatherManager.getWeather(
                            lat:latitude,
                            long:longitude)
                    }
                }
            }
        }
    }
}

#Preview {
    WeatherView(trip: Trip.exampleTrip)
}
