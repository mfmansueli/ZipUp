//
//  PackingListView.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI

struct PackingListView: View {
    
    @ObservedObject var trip: Trip
    @State private var bagBuilderShowing: Bool = false
    @State private var showReviseBagAlert: Bool = false
    
    var itemCount: Int {
        trip.getItemCount()
    }
    
    init(trip: Trip) {
        _trip = ObservedObject(wrappedValue: trip)
//        self.bagBuilderShowing = !trip.isBagDecided()
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    WeatherView(trip: trip)
                    
                    Divider()
                        .frame(width: 1, height: 100)
                        .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    Button {
                        showReviseBagAlert.toggle()
                    } label: {
                        BagProgressView(trip: trip, isOpen: true)
                            .frame(maxWidth: 100)
                    }
                    .foregroundStyle(.primary)
                }
                .frame(height: 100)
                .padding(.bottom, 20)
                
                Text("Your bag")
                    .font(.title)
                    .bold()
                
                List {
                    ForEach(ItemCategory.allCases, id: \.self) { category in
                        Section(
                            header: HStack {
                                Text(category.rawValue)
                                    .font(.title3)
                                    .bold()
                                
                                Spacer()
                                
                                HStack(spacing: 18) {
                                    Text("packed")
                                    Text("wearing")
                                    Text("n.items")
                                }
                                .foregroundStyle(.foreground.opacity(0.4))
                                .fontWeight(.light)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .padding(.trailing, 6)
                            }
                        ) {
                            SectionView(trip: _trip, category: category)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .padding(0)
            }
            .fullScreenCover(isPresented: $bagBuilderShowing) {
                BagBuilderView(trip: _trip)
            }
            .alert("Review your bag", isPresented: $showReviseBagAlert) {
                Button("Review bag") {
                    trip.undecideBag()
                    bagBuilderShowing.toggle()
                }
                
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Would you like to review your bag?")
            }
            .padding()
            .navigationTitle(trip.destinationName + " (\(trip.duration) days)")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    func addNewItem() {
        
    }
}

#Preview {
    PackingListView(trip: Trip.exampleTripDecided)
}
