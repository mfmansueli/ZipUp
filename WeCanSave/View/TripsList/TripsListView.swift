//
//  TripsListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI
import SwiftData

struct TripsListView: View {
    @ObservedObject private var viewModel = TripsListViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentation
    @Query(filter: #Predicate<Trip> { !$0.isFinished }) private var tripsCurrent: [Trip]
    @Query(filter: #Predicate<Trip> { $0.isFinished }) private var tripsPast: [Trip]
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    init() {
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                if tripsCurrent.isEmpty && tripsPast.isEmpty {
                    TripsListEmptyView()
                } else {
                    List {
                        if tripsCurrent.count > 0 {
                            Section(header: Text("Upcoming").font(.title)) {
                                ForEach(tripsCurrent) { trip in
                                    Button {
                                        viewModel.selectedTrip = trip
                                    } label: {
                                        TripListCardView(trip: trip)
                                    }
                                    .padding(.horizontal, 2)
                                    .foregroundStyle(Color.primary)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            deleteTrip(trip)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listSectionSeparator(.hidden)
                        }
                        if tripsPast.count > 0 {
                            Section(header: Text("Past").font(.title)) {
                                ForEach(tripsPast) { trip in
                                    Button {
                                        viewModel.selectedTrip = trip
                                    } label: {
                                        TripListCardView(trip: trip, isPast: true)
                                    }
                                    .padding(.horizontal, 2)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            deleteTrip(trip)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listSectionSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
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
            }
            .navigationTitle("ZipUp")
        } detail: {
            if let trip = viewModel.selectedTrip {
                PackingListView(trip: trip)
        } else {
            ContentUnavailableView {
                Label("No Trip Selected", systemImage: "exclamationmark.triangle.fill")
            } description: {
                Text("Please select a trip to view the packing list.")
            }
        }
        }
        .sheet(isPresented: $viewModel.showTripPlanner) {
            TripPlannerView(modelContext: modelContext, selectedTrip: $viewModel.selectedTrip)
                .presentationBackground(.thickMaterial)
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private func deleteTrip(_ trip: Trip) {
        withAnimation {
            modelContext.delete(trip)
        }
    }
}

#Preview {
    TripsListView()
        .modelContainer(for: Trip.self, inMemory: true)
}
