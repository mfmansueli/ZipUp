//
//  TripsListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI
import SwiftData

struct TripsListView: View {
    @StateObject private var viewModel = TripsListViewModel()
    @Environment(\.modelContext) private var modelContext
     @Environment(\.presentationMode) var presentation
    @Query(filter: #Predicate<Trip> { !$0.isFinished }) private var tripsCurrent: [Trip]
    @Query(filter: #Predicate<Trip> { $0.isFinished }) private var tripsPast: [Trip]
//    @State private var tripsCurrent: [Trip] = [Trip.exampleTrip, Trip.exampleTrip, Trip.exampleTrip]
//    @State private var tripsPast: [Trip] = [Trip.exampleTrip, Trip.exampleTrip]

    var body: some View {
        NavigationSplitView {
            VStack {

                if tripsCurrent.isEmpty && tripsPast.isEmpty {
                    TripsListEmptyView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            if tripsCurrent.count > 0 {
                                Section(header:
                                            Text("Upcoming").font(.title)
                                ) {
                                    ForEach(tripsCurrent) { trip in
                                        Button {
                                            viewModel.selectedTrip = trip
                                        } label: {
                                            TripListCardView(trip: trip)
                                        }
                                        .padding(.horizontal, 2)
                                        .foregroundStyle(Color.primary)
                                    }
                                }
                            }
                            if tripsPast.count > 0 {
                                Section(header:
                                            Text("Past").font(.title)
                                ) {
                                        ForEach(tripsPast) { trip in
                                            Button {
                                                viewModel.selectedTrip = trip
                                            } label: {
                                                TripListCardView(trip: trip, isPast: true)
                                            }
                                            .padding(.horizontal, 2)
                                        }
                                }
                            }

                        }
                        .padding()
                    }
                    .foregroundStyle(Color.primary)
                }
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
            TripPlannerView(modelContext: modelContext)
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
