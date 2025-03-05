//
//  BagBuilderView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 03/03/25.
//

import SwiftUI

struct BagBuilderView: View {
    
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
        print(count)
        return count
    }
    
    init(trip: Trip) {
        self.trip = trip
        self.itemList = trip.bag!.itemList
        
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Paris (5 days)")
                    .padding(.horizontal)
                
                Divider()
                    .frame(width: 1, height: 80)
                
                BagProgressView(bagProgress: progress, isOpen: false, itemCount: itemCount)
                    .frame(height: 180) // Ensures it has a defined size
//                    .zIndex(1)
            }
            
//            Spacer()
            Text("Add or remove our suggestions for your bag")
//                .font(.callout)
                .foregroundStyle(.foreground.opacity(0.5))
            
            SwipeView(itemList: $itemList)
            
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

#Preview {
    BagBuilderView(trip: Trip.exampleTrip)
}
