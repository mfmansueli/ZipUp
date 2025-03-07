//
//  TripsListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI
import SwiftData

struct TripsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    
    @State private var items = Bag.exampleBag.itemList
    
    @State private var tripPlannerShowing: Bool = false
    
    var body: some View {
        NavigationSplitView {
            VStack {
                Spacer()

                if trips.isEmpty {

                    Text("Where are you going next?")
                        .font(.system(size: 60, weight: .bold))
                        .padding(50)
                        .multilineTextAlignment(.center)
                        .listRowSeparator(.hidden)
                        
                } else {
                    List {
                        
                        ForEach(trips) { trip in
                            NavigationLink {
                                PackingListView(trip: trip)
                            } label: {
                                Text("\(trip.destinationName)")
                            }
                        }
        //                .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                    .accessibilityLabel("Your upcoming trips")
                }
                
                Spacer()

                
            }
            
            .toolbar {

                ToolbarItem(placement: .bottomBar) {
                    Button {
                        tripPlannerShowing.toggle()
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        modelContext.insert(
                            Trip(
                                destinationName: "London",
                                destinationLat: "39.14",
                                destinationLong: "-120.25",
                                startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!,
                                endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 24))!,
                                category: "Culture"
                            )
                        )
                    } label: {
                        Text("Add fake trip")
                    }
                }
            }
        } detail: {
            //
        }
        .sheet(isPresented: $tripPlannerShowing) {
            TripPlannerView()
        }
    }

    private func addItem() {
        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    TripsListView()
        .modelContainer(for: Trip.self, inMemory: true)
}
