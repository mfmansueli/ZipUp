//
//  SectionView.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 25/04/25.
//

import Foundation
import SwiftUI

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
            HStack {
                ZStack(alignment: .topLeading) {
                    NavigationLink {
                        SwipeView(trip: trip, item: item, category: category, isEditMode: true, singleItemDisplay: true)
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    Text(item.name)
                        .foregroundStyle(.accent)
                        .padding(0)
                }
                
                HStack(spacing: 34) {
                    PackedButton(item: item)
                    WearingButton(item: item)
                    Text("x\(item.userQuantity)")
                        .font(.title2)
                        .frame(width: 35)
                }
                .multilineTextAlignment(.trailing)
            }
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
            SwipeView(trip: trip, category: category, isEditMode: true, singleItemDisplay: true)
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

struct WearingButton: View {
    
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

struct PackedButton: View {
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
