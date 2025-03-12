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
    @Query(filter: #Predicate<Trip> { !$0.isFinished }) private var tripsCurrent: [Trip]
    @Query(filter: #Predicate<Trip> { $0.isFinished }) private var tripsPast: [Trip]
//    @State private var tripsCurrent: [Trip] = [Trip.exampleTrip, Trip.exampleTrip, Trip.exampleTrip]
//    @State private var tripsPast: [Trip] = [Trip.exampleTrip, Trip.exampleTrip]

    @State private var items = Bag.exampleBag.itemList

    var body: some View {
        NavigationSplitView {
            VStack {
//                Spacer()

                if tripsCurrent.isEmpty && tripsPast.isEmpty {
                    TripsListEmptyView()
                } else {
                    VStack(alignment: .leading, spacing: 40) {
                        Section(header:
                            Text("Upcoming").font(.title)
                        ) {
                            List {
                                ForEach(tripsCurrent) { trip in
                                    Button {
                                        viewModel.selectedTrip = trip
                                    } label: {
                                        TripListCardView(trip: trip)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 2)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                            }
                            .listStyle(.plain)
//                         
                        }

                        Section(header:
                            Text("Past").font(.title)
                        ) {
                            List {
                                ForEach(tripsCurrent) { trip in
                                    Button {
                                        viewModel.selectedTrip = trip
                                    } label: {
                                        TripListCardView(trip: trip, isPast: true)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 2)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                            }
                            .listStyle(.plain)
                        }
                        
                       
                        
//                        Spacer()

                    }
                    .padding()
                }
//                Spacer()
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
                        Label("Add trip", systemImage: "plus.circle.fill")
                            .labelStyle(.titleAndIcon)
                            .padding()
                    }.buttonStyle(.borderless)
                }

                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
            }.navigationTitle("ZipUp")
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
