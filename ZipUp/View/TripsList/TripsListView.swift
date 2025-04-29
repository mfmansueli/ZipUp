//
//  TripsListView.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI
import SwiftData

private let currentDate = Date()

struct TripsListView: View {
    @ObservedObject private var viewModel = TripsListViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentation

    @Query(filter: #Predicate<Trip> { $0.endDate < currentDate }) private var tripsPast: [Trip]
    @Query(filter: #Predicate<Trip> { $0.endDate > currentDate }) private var tripsCurrent: [Trip]
    
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
                            createSection(header: "Upcoming", trips: tripsCurrent)
                        }
                        if tripsPast.count > 0 {
                            createSection(header: "Past", trips: tripsPast, isPast: true)
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
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
            TripPlannerView(modelContext: modelContext,
                            selectedTrip: $viewModel.selectedTrip)
            .presentationBackground(.thickMaterial)
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private func createSection(header: LocalizedStringKey, trips: [Trip], isPast: Bool = false) -> some View {
        Section(header:
                    Text(header)
            .font(.title)
        ) {
            ForEach(trips) { trip in
                Button {
                    viewModel.selectedTrip = trip
                } label: {
                    TripListCardView(trip: trip, isPast: isPast)
                }
                .padding(.vertical, 8)
                .foregroundStyle(Color.primary)
            }
            .onDelete(perform: deleteTrip)
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
    }
    
    private func deleteTrip(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tripsCurrent[index])
            }
        }
    }
}

#Preview {
    TripsListView()
        .modelContainer(for: Trip.self, inMemory: true)
}
