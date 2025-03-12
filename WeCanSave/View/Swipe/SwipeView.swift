//
//  SwipeView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 26/02/25.
//

import SwiftUI

struct SwipeView: View {
    
    // user.trip id = trip id
    
    // trip.bag
    
    @Binding var itemList: [Item]
    
    var body: some View {
        ZStack {
            ForEach(0..<itemList.count, id: \.self) { index in
                ItemView(item: $itemList[index]) {
                    withAnimation {
                        removeItem(at: index)
                    }
                }
                .stacked(at: index, in: itemList.count)
                .accessibilityHidden(index == itemList.count - 1 ? false : true)
            
            }
        }
    }
    
    func removeItem(at index: Int) {
        itemList.remove(at: index)
        
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(x: offset * Double.random(in: -3...3), y: offset * Double.random(in: -3...3))
    }
}

#Preview {
    SwipeView(itemList: .constant(Bag.exampleBag.itemList))
}
