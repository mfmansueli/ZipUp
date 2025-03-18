//
//  BagProgressView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 03/03/25.
//

import SwiftUI

struct BagProgressView: View {
    
    @State var trip: Trip
    @State var bagProgress: Double
    @State var isOpen: Bool
    @State var showProgress: Bool
    @State var itemCount: Int = 0
    
    init(trip: Trip, bagProgress: Double, isOpen: Bool, showProgress: Bool, itemCount: Int) {
        self.trip = trip
        self.bagProgress = bagProgress
        self.isOpen = isOpen
        self.showProgress = showProgress
        self.itemCount = itemCount
        
        print("bagProgress \(bagProgress)")
    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 1)
            .rotation(.degrees(-90))
            .stroke(.brandGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
            .background {
                Image(isOpen ? "Bag_open-symbol" : "Bag_closed-symbol")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.brandOrange)
                    .padding(16)
            }
            .overlay {
                HStack {
                    VStack(alignment: .leading) {
                        Spacer()
                        Text("\(itemCount)")
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .padding(5)
                            .background(
                                Circle()
                                    .fill(.background)
                                    .stroke(.foreground, lineWidth: 2)
                            )
                    }
                    Spacer()
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Bag builder progress: Suggestions remaining; \(itemCount)")
    }
}

#Preview {
    BagProgressView(trip: Trip.exampleTrip, bagProgress: 0.8, isOpen: false, showProgress: true, itemCount: 10)
}

#Preview {
    PackingListView(trip: Trip.exampleTripDecided)
}
