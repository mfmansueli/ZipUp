//
//  PackingListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI

struct PackingListView: View {
    
    @State var trip: Trip
    
    @State private var bagBuilderShowing: Bool
    
    init(trip: Trip) {
        self.trip = trip
        self.bagBuilderShowing = !trip.bag!.isDecided
    }
    
    var body: some View {
        VStack {
            
            Text("Test")
            
            List {
                ForEach(trip.bag?.itemList ?? [], id: \.id) { item in
                    Text("\(item.name)")
                }
            }
        }
        .fullScreenCover(isPresented: $bagBuilderShowing) {
            BagBuilderView(trip: trip)
        }
    }
}

#Preview {
    PackingListView(trip: Trip.exampleTrip)
}
