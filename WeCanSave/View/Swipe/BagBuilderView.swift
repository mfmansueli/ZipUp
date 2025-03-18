//
//  BagBuilderView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 03/03/25.
//

import SwiftUI

struct BagBuilderView: View {
    
    @Environment(\.presentationMode) var presentation
    @Binding var trip: Trip
    @State var totalCards: Int = 0

    var itemCount: Int {
        return trip.getItemCount()
    }
    
    init(trip: Binding<Trip>) {
        _trip = trip
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    HStack {
                        Image(systemName: "xmark")
                            .foregroundStyle(.red.opacity(0.4))
                            .padding(.leading, 6)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .foregroundStyle(.green.opacity(0.4))
                            .padding(.trailing, 6)
                    }
                    .font(.title2)
                    .offset(y: 50)
                    
                    VStack(spacing: 35) {
                        HStack {
                            WeatherView(trip: trip)
                            
                            Divider()
                                .frame(width: 1, height: 100)
                            
                            Button {
                                presentation.wrappedValue.dismiss()
                            } label: {
                                BagProgressView(trip: $trip, isOpen: false)
                                    .frame(maxWidth: 100)
                            }
                            .foregroundStyle(.primary)
                        }
                        .frame(height: 100)
                        
                        Text("Swipe to add or remove our suggestions from your bag")
                            .font(.system(size: 14))
                            .foregroundStyle(.foreground.opacity(0.4))
                            .multilineTextAlignment(.center)
                        
                        SwipeView(itemList: $trip.itemList)
                        
                        Button("All good, take me to the bag!") {
                            presentation.wrappedValue.dismiss()
                        }
                        .buttonStyle(.bordered)
                        .tint(.accent)
                        .clipShape(Capsule())
                    }
                    .onAppear {
                        totalCards = trip.itemList.count
                    }
                    .padding()
                }
                .navigationTitle(trip.destinationName + " (\(trip.duration) days)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            presentation.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.down")
//                            Text("close")
                        }
                        
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

#Preview {
    BagBuilderView(trip: .constant(Trip.exampleTrip))
}

