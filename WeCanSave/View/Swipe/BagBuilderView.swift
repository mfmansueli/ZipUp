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
        var count: Int = 0
        
        for item in itemList {
            if item.isDecided {
                count += item.userQuantity
            }
        }
        //        print(count)
        return count
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
                    Text("Paris (5 days)")
                        .padding(.horizontal)
                        .frame(width: geometry.size.width * 0.6 - 20)
                    
                    Divider()
                        .frame(width: 1, height: 80)
                        .padding()
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        BagProgressView(bagProgress: progress, isOpen: false, showProgress: true, itemCount: itemCount)
                        //                        .frame(height: 180) // Ensures it has a defined size
                    }
                    
                }
                .frame(height: 100)
                .padding(.bottom, 40)
                
                
                
                Text("Add or remove our suggestions for your bag")
                //                .font(.callout)
                    .foregroundStyle(.foreground.opacity(0.5))
                //                .accessibilitySortPriority(1)
                
                SwipeView(itemList: $itemList)
                //                .accessibilitySortPriority(2)
                
                Button("All good, take me to the bag!") {
                    print(itemList.count)
                }
                .buttonStyle(.bordered)
            }
            .onAppear {
                totalCards = itemList.count
            }
        }
    }
}

#Preview {
    BagBuilderView(trip: Trip.exampleTrip)
}
