//
//  SwipeView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 26/02/25.
//

import SwiftUI

struct SwipeView: View {
    
    @Environment(\.presentationMode) var presentation
    @Binding var itemList: [Item]
    var addNewItem: ((_ itemList: [Item]) -> Void)? = nil
    
    var body: some View {
        ZStack {
            ForEach(0..<itemList.count, id: \.self) { index in
                ItemView(item: $itemList[index]) {
                    withAnimation {
                        itemList[index].trip?.remove(item: itemList[index])
                        checkBag()
                    }
                } added: {
                    checkBag()
                    addNewItem?(itemList)
                }
                .stacked(at: index, in: itemList.count)
                .accessibilityHidden(index == itemList.count - 1 ? false : true)
            }
        }
    }
    
    func isListDecided() -> Bool {
        for item in itemList {
            if !item.isDecided {
                return false
            }
        }
        return true
    }
    
    func checkBag() {
        if itemList.isEmpty || isListDecided() {
            presentation.wrappedValue.dismiss()
        }
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
//        return self.offset(x: offset * Double.random(in: -1...1), y: offset * Double.random(in: -1...1))
        return self.offset(x: offset * Double.random(in: -0.2...0.2), y: offset * Double.random(in: -0.2...0.2))
    }
}

#Preview {
    SwipeView(itemList: .constant(Trip.exampleTrip.itemList ?? []))
}
