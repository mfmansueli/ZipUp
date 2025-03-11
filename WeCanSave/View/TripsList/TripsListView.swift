//
//  TripsListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI
import SwiftData

struct TripsListView: View {
    @ObservedObject var viewModel = TripsListViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    
    @State private var items = Bag.exampleBag.itemList
    
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
                }
                Spacer()
            }
            .navigationDestination(item: $viewModel.selectedTrip,
                                   destination: { item in
                PackingListView(trip: item)
            })
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    
                    Button {
                        
                        viewModel.showTripPlanner.toggle()
                    } label: {
                        Label("Add new trip", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }.buttonStyle(.borderless)
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
            }
        } detail: {
            //
        }
        .sheet(isPresented: $viewModel.showTripPlanner) {
            TripPlannerView(selectedTrip: $viewModel.selectedTrip)
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
