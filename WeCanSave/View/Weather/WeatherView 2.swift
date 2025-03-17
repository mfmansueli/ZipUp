//
//  WeatherView.swift
//  WeCanSave
//
//  Created by Lehebel Florence on 10/03/25.
//
//
//import SwiftUI
//import WeatherKit
//import CoreLocation
//
//struct WeatherView2: View {
//    @State private var weatherManager: WeatherViewModel
//    @State private var isExpanded = false // Add state for expansion
//    
//    var trip: Trip
//    var latitude: Double { Double(trip.destinationLat) ?? 0.0 }
//    var longitude: Double { Double(trip.destinationLong) ?? 0.0 }
//    
//    // Add date formatter
//    private let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter
//    }()
//    //    let paris = CLLocation(latitude: 48.8566, longitude: 2.3522)
//    
//    init(trip: Trip) {
//        self.trip = trip
//        self.weatherManager = WeatherViewModel(trip: trip)
//    }
//    
//    var body: some View {
//        Button(action: { isExpanded.toggle() }) {
//            ZStack {
//                VStack(alignment: .leading, spacing: 0) {
//                    HStack {
//                        // Location and duration
//                        HStack{
////                            Text(trip.destinationName)
////                                .font(.title)
////                                .foregroundColor(.black)
////                                .lineLimit(1)
////                                .bold()
//                            //                        Text("\(weatherManager.temperature)")
//                            //                        Button(action: { isExpanded.toggle() }) {
////                            Spacer()
//
//                            HStack {
//                                //Number of days
//                                Text("\(shortDateString(startDate: trip.startDate, endDate: trip.endDate))")
//                                    .font(.headline)
//                                    .fontWeight(.semibold)
//                                    .foregroundColor(.primary)
//
//                                Image(systemName: "chevron.down.circle")
//                                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
//                                    .animation(.easeInOut, value: isExpanded)
//                            }
//
//                            Spacer()
//
//                            //                        }
//                            //Start and End date
//                            //                        VStack(alignment: .leading) {
//                            //                            Text(dateFormatter.string(from: trip.startDate))
//                            //                            Text(dateFormatter.string(from: trip.endDate))
//                            //                        }
//                            //                        .font(.caption)
//                            .popover(isPresented: $isExpanded) {
//
//                                VStack(spacing: 15) {
//                                    ForEach(weatherManager.dailyForecasts, id: \.date) { forecast in
//                                        HStack {
//                                            Text(forecast.date, style: .date)
//                                                .frame(width: 100, alignment: .leading)
//
//                                            Text(forecast.maxTemp)
//                                                .frame(width: 50)
//
//                                            Text(forecast.minTemp)
//                                                .foregroundColor(.gray)
//                                                .frame(width: 50)
//                                            Image(systemName: forecast.icon)
//                                                .frame(width: 30)
//                                            Text(forecast.description)
//                                                .frame(maxWidth: .infinity, alignment: .leading)
//                                        }
//                                        .padding(.horizontal)
//                                    }
//                                }
//                                .foregroundColor(.black)
//
//                                    .presentationCompactAdaptation(.popover)
//                                .padding(.vertical)
//                            }
//                        }
//                        .padding(.bottom, 10)
//
//
//                    }
////                    .padding(.horizontal, 20)
//
////                    Spacer()
//
//                    HStack(alignment: .bottom) {
//                        VStack {
//                            //averageMaxTemp
//                            HStack(spacing: 5) {
//                                Text(weatherManager.averageMaxTemperature) // Update this line
//                                    .font(.title2)
//                                    .fontWeight(.light)
//                                    .foregroundColor(.black)
//
//                                Text("avg. max.")
//                                    .font(.body)
//                                    .fontWeight(.light)
//                                    .foregroundColor(.black)
//
//                            }
//                            Spacer()
//
//                            //averageMinTemp
//                            HStack(spacing: 4) {
//                                Text(weatherManager.averageMinTemperature)
//                                    .font(.title2)
//                                    .fontWeight(.light)
//                                    .foregroundColor(.gray)
//                                Text("avg. min.")
//                                    .font(.body)
//                                    .fontWeight(.light)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//
//                        Spacer()
//
//
//
//                        VStack(spacing: 8) {
//                            Image(systemName: weatherManager.averageWeatherCondition.icon)
//    //                            .font(.system(size: 80))
//                                .resizable()
//                                .scaledToFill()
//                                .foregroundColor(.black)
//                                .frame(maxWidth: 50)
//
//                            Text(weatherManager.averageWeatherCondition.description.lowercased())
//                                .font(.body)
//                                .fontWeight(.thin)
//                                .foregroundColor(.black)
//
//                    }
//                        .padding(.trailing, 20)
//
//
//
//                    }
////                    .padding(.top, 10)
//                }
//                .onAppear {
//                    Task {
//                        await weatherManager.getWeather(
//                            lat:latitude,
//                            long:longitude)
//                    }
//                }
//            }
//        }
//    }
//

//}
//
//#Preview {
////    WeatherView(trip: Trip.exampleTrip)
//    BagBuilderView(trip: Trip.exampleTrip)
//}
//#Preview {
//    WeatherView2(trip: Trip.exampleTrip)
////    BagBuilderView(trip: Trip.exampleTrip)
//}
