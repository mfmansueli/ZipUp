//
//  BagProgressView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 03/03/25.
//

import SwiftUI

struct BagProgressView: View {
    
    @Environment(\.presentationMode) var presentation
    @Binding var trip: Trip
    @State var isOpen: Bool
    
//    init(trip: Trip, isOpen: Bool) {
//        self.trip = trip
//        self.isOpen = isOpen
//    }
    
    var body: some View {
        Circle()
            .trim(from: 0, to: trip.progress)
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
                        Text("\(trip.getItemCount())")
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .background(
                                Circle()
                                    .fill(.background)
                                    .stroke(.foreground, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            )
                            .padding(16)
                    }
                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 1.0), value: trip.progress)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Bag builder progress: Suggestions remaining; \(trip.getItemCount())")
    }
}

#Preview {
    BagProgressView(trip: .constant(Trip.exampleTrip), isOpen: true)
}

#Preview {
    PackingListView(trip: Trip.exampleTripDecided)
}
