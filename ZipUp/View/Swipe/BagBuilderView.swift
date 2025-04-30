//
//  BagBuilderView.swift
//  ZipUp
//
//  Created by Mathew Blanc on 03/03/25.
//

import SwiftUI

struct BagBuilderView: View {
    
    @Environment(\.presentationMode) var presentation
    @ObservedObject var trip: Trip
    @State var totalCards: Int = 0

    var itemCount: Int {
        return trip.getItemCount()
    }
    
    init(trip: ObservedObject<Trip>) {
        _trip = trip
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    
                    VStack(spacing: 35) {
                        HStack {
                            WeatherView(trip: trip)
                            
                            Divider()
                                .frame(width: 1, height: 100)
                            
                            Spacer()
                            
                            Button {
                                presentation.wrappedValue.dismiss()
                            } label: {
                                BagProgressView(trip: trip, isOpen: false)
                                    .frame(maxWidth: 100)
                            }
                            .foregroundStyle(.primary)
                        }
                        .frame(height: 100)
                        
                        Text("Swipe to add or remove our suggestions from your bag")
                            .font(.system(size: 14))
                            .foregroundStyle(.foreground.opacity(0.4))
                            .multilineTextAlignment(.center)
                        
                        SwipeView(trip: trip, isEditMode: false)
                        
                        Button("All good, take me to the bag!") {
                            presentation.wrappedValue.dismiss()
                        }
                        .buttonStyle(.bordered)
                        .tint(.accent)
                        .clipShape(Capsule())
                    }
                    .onAppear {
                        totalCards = trip.itemList?.count ?? 0
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

//#Preview {
//    BagBuilderView(trip: .constant(Trip.exampleTrip))
//}

