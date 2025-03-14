//
//  BagBuilderView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 03/03/25.
//

import SwiftUI

struct BagBuilderView: View {
    
    @Environment(\.presentationMode) var presentation
    @State private var trip: Trip
    
    @State var itemList: [Item]
    
    @State var totalCards: Int = 0
    
    var progress: Double {
        1.0 - Double(itemList.count) / Double(totalCards)
    }
    
    var itemCount: Int {
//        print(trip.bag!.getItemCount())
        return trip.getItemCount()

    }
    
    init(trip: Trip) {
        self.trip = trip
        self.itemList = trip.itemList
        
        print(trip.itemList)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                HStack {
                    WeatherView2(trip: trip)
                        .frame(width: geometry.size.width * 0.6 - 20)
                    
                    Divider()
                        .frame(width: 1, height: 100)
                        .padding(.trailing, 20)
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        BagProgressView(bagProgress: progress, isOpen: false, showProgress: true, itemCount: itemCount)
                            .frame(width: geometry.size.width * 0.4 - 40)
                    }
                    .foregroundStyle(.primary)
                    .padding(0)

                }
                .frame(height: 100)
                .padding(.bottom, 20)
//                .padding(.trailing, 20)
                
                
                
                Text("Add or remove our suggestions for your bag")
                //                .font(.callout)
                    .foregroundStyle(.foreground.opacity(0.5))
                    .padding(.vertical, 15)
                //                .accessibilitySortPriority(1)
                
                SwipeView(itemList: $itemList)
                //                .accessibilitySortPriority(2)
                
                Button("All good, take me to the bag!") {
                    print(itemList.count)
                }
                .buttonStyle(.bordered)
                .padding(.top, 20)
            }
            .onAppear {
                totalCards = itemList.count
            }
            .padding()
        }
    }
}

#Preview {
    BagBuilderView(trip: Trip.exampleTrip)
}

