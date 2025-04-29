//
//  SwipeView.swift
//  ZipUp
//
//  Created by Mathew Blanc on 26/02/25.
//

import SwiftUI

struct SwipeView: View {
    
    @Environment(\.presentationMode) var presentation
    var trip: Trip
    var item: Item?
    var singleItemDisplay: Bool
    var category: ItemCategory = .clothing
    @State var isEditMode: Bool = false
    
    init(trip: Trip, item: Item? = nil, category: ItemCategory = .clothing, isEditMode: Bool = false, singleItemDisplay: Bool = false) {
        self.trip = trip
        self.item = item
        self.category = category
        self.singleItemDisplay = singleItemDisplay
        _isEditMode = State(initialValue: isEditMode)
    }
    
    var body: some View {
        ZStack {
            if singleItemDisplay {
                itemViewBuilder(item, 0)
            } else if let itemList = trip.itemList {
                ForEach(0..<itemList.count, id: \.self) { index in
                    itemViewBuilder(trip.itemList?[index], index)
                }
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditMode ? "Done" : "Edit") {
                    isEditMode.toggle()
                }
            }
        }
    }
    
    fileprivate var itemViewBuilder: (Item?, Int) -> AnyView {
        { item, index in
            AnyView(
                ItemView(item: item, isEditMode: $isEditMode, category: category) { draftItem in
                    withAnimation {
                        print("Item removed")
                        trip.remove(item: draftItem.toItem())
                        checkBag()
                    }
                } added: { draftItem in
                    print("Item added")
                    let item = draftItem.toItem()
                    item.trip = trip
                    trip.addItem(item)
                    checkBag()
                }
                    .stacked(at: index, in: item == nil ? 0 : trip.itemList?.count ?? 0)
                    .accessibilityHidden(index == trip.itemList?.count ?? 0 - 1 ? false : true)
            )
        }
    }
    
    func isListDecided() -> Bool {
        guard let itemList = trip.itemList else { return false }
        for item in itemList {
            if !item.isDecided {
                return false
            }
        }
        return true
    }
    
    func checkBag() {
        if trip.isBagDecided() {
            print("Bag is decided")
            presentation.wrappedValue.dismiss()
        }
    }
}

#Preview {
    SwipeView(trip: Trip.exampleTrip)
}
