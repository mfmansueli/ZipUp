//
//  PackingListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI

struct PackingListView: View {
    
    var trip: Trip
    
    @State private var bagBuilderShowing: Bool
    
    //    @State private var addItemSheetShowing: Bool = false
    
    var itemCount: Int {
        trip.getItemCount()
    }
    
    init(trip: Trip) {
        self.trip = trip
        self.bagBuilderShowing = !trip.isBagDecided()
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                HStack {
                    WeatherView(trip: trip)
                    
                    Divider()
                        .frame(width: 1, height: 100)
                        .padding(.horizontal, 10)
                    
                    Button {
                        bagBuilderShowing = true
                    } label: {
                        BagProgressView(trip: trip,
                                        bagProgress: trip.progress,
                                        isOpen: false,
                                        showProgress: true,
                                        itemCount: trip.getItemCount())
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
                            }
                        ) {
                            SectionView(trip: trip, category: category)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .padding(0)
                
                
            }
            .fullScreenCover(isPresented: $bagBuilderShowing) {
                BagBuilderView(trip: trip)
            }
            //                .sheet(isPresented: $addItemSheetShowing, content: {
            //                    EmptyView()
            //                })
            .padding()
            .navigationTitle(trip.destinationName + " (\(trip.duration) days)")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

#Preview {
    PackingListView(trip: Trip.exampleTripDecided)
}


struct ListItemView: View {
    
    @Binding var item: Item
    
    var body: some View {
        HStack {
            ZStack(alignment: .topLeading) {
                NavigationLink {
                    SwipeView(itemList: Binding(
                        get: { [item] },
                        set: { newItems in
                            if let first = newItems.first {
                                item = first
                            }
                        }
                    ))
                } label: {
                    //                    Text(item.name)
                    //                        .foregroundStyle(.accent)
                    //                    //                    .font(.title3)
                    //                        .padding(0)
                    EmptyView()
                }
                //                .buttonStyle(PlainButtonStyle())
                .opacity(0)
                
                Text(item.name)
                    .foregroundStyle(.accent)
                //                    .font(.title3)
                    .padding(0)
            }
            
            
            
            
            //            Spacer()
            HStack(spacing: 35) {
                ListItemPackedButton(item: $item)
                ListItemWearingButton(item: $item)
                Text("x\(item.userQuantity)")
                    .font(.title2)
            }
            
        }
    }
}

struct ListItemWearingButton: View {
    
    @Binding var item: Item
    
    var isSingular: Bool {
        item.userQuantity == 1
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(isSingular ? "jacket_button" : item.isWearing ? "Jacket_1" : "jacket_button")
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .foregroundColor(item.isWearing ? Color.accent : Color.primary.opacity(0.4))
                .padding(.top, 5)
                .onTapGesture {
                    if isSingular && item.isPacked && item.isWearing == false {
                        item.isPacked = false
                    }
                    item.isWearing.toggle()
                }
        }
    }
}

struct ListItemPackedButton: View {
    
    @Binding var item: Item
    
    var isSingular: Bool {
        item.userQuantity == 1
    }
    
    var body: some View {
        Image("Check")
            .resizable()
            .scaledToFill()
            .frame(width: 30, height: 30)
            .foregroundStyle(item.isPacked ? Color.accent : Color.primary.opacity(0.4))
        //            .font(.system(size: 20))
            .padding(.top, 5)
            .onTapGesture {
                if isSingular && item.isWearing && item.isPacked == false {
                    item.isWearing = false
                }
                item.isPacked.toggle()
            }
    }
}

struct SectionView: View {
    @State var trip: Trip
    @State var showAddItemSheet: Bool = false
    var filteredItems: [Item] = []
    
    init(trip: Trip, category: ItemCategory) {
        self.trip = trip
        filteredItems = trip.itemList.filter { $0.category == category }
    }
    
    var body: some View {
        ForEach(filteredItems, id: \.self) { item in
            if let item = $trip.itemList.first(where: { $0.id == item.id }) {
                ListItemView(item: item)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
            }
        }
        HStack {
            Button("Add item") {
                showAddItemSheet = true
            }
            Spacer()
            
            Image(systemName: "plus.square")
                .font(.title3)
        }
        .foregroundStyle(.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
    }
}
