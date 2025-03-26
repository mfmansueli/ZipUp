//
//  PackingListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI

struct PackingListView: View {
    
    @ObservedObject var trip: Trip
    @State private var bagBuilderShowing: Bool
    
    var itemCount: Int {
        trip.getItemCount()
    }
    
    init(trip: Trip) {
        _trip = ObservedObject(wrappedValue: trip)
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
                    
                    Spacer()
                    
                    Button {
                        bagBuilderShowing = true
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

struct ListItemView: View {
    
    var item: Item
    
    var body: some View {
        HStack {
            ZStack(alignment: .topLeading) {
                NavigationLink {
                    SwipeView(itemList: Binding(
                        get: { [item] },
                        set: { newItems in
//                            if let first = newItems.first {
//                                item = first
//                            }
                        }
                    ), addNewItem: nil)
                } label: {
                    EmptyView()
                }
                .opacity(0)
                
                Text(item.name)
                    .foregroundStyle(.accent)
                    .padding(0)
            }
            
            HStack(spacing: 34) {
                ListItemPackedButton(item: item)
                ListItemWearingButton(item: item)
                Text("x\(item.userQuantity)")
                    .font(.title2)
                    .frame(width: 35)
            }
            .multilineTextAlignment(.trailing)
        }
    }
}

struct ListItemWearingButton: View {
    
    var item: Item
    
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
    
    var item: Item
    
    var isSingular: Bool {
        item.userQuantity == 1
    }
    
    var body: some View {
        Image("Check")
            .resizable()
            .scaledToFill()
            .frame(width: 30, height: 30)
            .foregroundStyle(item.isPacked ? Color.accent : Color.primary.opacity(0.4))
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
    @ObservedObject var trip: Trip
    @State private var showAddItem: Bool = false
    @State private var itemName: String = ""
    @State private var itemQuantity: Int = 1
    var filteredItems: [Item] = []
    var category: ItemCategory
    
    enum FocusedField {
        case name, qty
    }
    
    @FocusState private var focusedField: FocusedField?
    
    init(trip: ObservedObject<Trip>, category: ItemCategory) {
        _trip = trip
        self.category = category
        filteredItems = trip.wrappedValue.getItems(byCategory: category)
    }
    
    var body: some View {
        ForEach(filteredItems, id: \.self) { item in
            
//            if let index = trip.itemList?.firstIndex(of: item),
//               let item = $trip.itemList[index] {
//                
//                ListItemView(item: item)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 20)
//            }
//            if let item = $trip.itemList?.first(where: { test in test.id == item.id }) {
                ListItemView(item: item)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
//            }
        }
        HStack {
            Button("Add item") {
                showAddItem.toggle()
                focusedField = .name
            }
            Spacer()
            
            Image(systemName: "plus.square")
                .font(.title3)
        }
        .foregroundStyle(.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .navigationDestination(isPresented: $showAddItem) {
            SwipeView(itemList: Binding(
                get: { [Item(category: category, trip: trip)] },
                set: { _ in }
            )) { itemList in
//                trip.itemList.append(contentsOf: itemList)
            }
        }
    }
    
    private func addNewItem() {
        let newItem = Item(
            name: itemName,
            category: category,
            userQuantity: itemQuantity,
            AIQuantity: itemQuantity
        )
        
        trip.addItem(newItem)
        itemName = ""
        itemQuantity = 1
        showAddItem.toggle()
    }
}

