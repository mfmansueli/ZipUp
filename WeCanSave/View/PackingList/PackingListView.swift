//
//  PackingListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI

struct PackingListView: View {
    
    @State var trip: Trip
    
    @State private var bagBuilderShowing: Bool
    
    
    
    init(trip: Trip) {
        self.trip = trip
        self.bagBuilderShowing = false //!trip.bag!.isDecided
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    HStack {
                        Text("Paris (5 days)")
                        //                        .padding(.horizontal)
                            .frame(width: geometry.size.width * 0.6 - 20)
                        
                        Divider()
                            .frame(width: 1, height: 80)
                            .padding()
                        
                        BagProgressView(bagProgress: 1, isOpen: true, showProgress: false, itemCount: trip.bag!.itemList.count)
                        
                    }
                    .frame(height: 100)
                    
                    Text("Your bag")
                        .font(.title).bold()
                    
                    let groupedItems = Dictionary(grouping: trip.bag?.itemList ?? [], by: { $0.category })
                    
                    List {
                        ForEach(groupedItems.keys.sorted(), id: \.self) { category in
                            Section(
                                header: HStack {
                                    Text(category).font(.title2).bold()
                                    Spacer()
                                    
                                    HStack(spacing: 18) {
                                        Text("packed")
                                        Text("wearing")
                                        Text("n.items")
                                    }
                                    .foregroundStyle(.foreground.opacity(0.4))
                                    .fontWeight(.light)
                                    .multilineTextAlignment(.center)
                                }
                            ) {
                                
                                let filteredItems = trip.bag.itemList.filter { $0.category == category }
                                
                                ForEach(filteredItems.indices, id: \.self) { index in
                                    
                                    let item = $trip.bag.itemList.first(where: { $0.id == filteredItems[index].id })!
                                    
                                    
                                    ListItemView(item: item)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 20)
                                    
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    .listStyle(.plain)
                    
                    
                }
                .fullScreenCover(isPresented: $bagBuilderShowing) {
                    BagBuilderView(trip: trip)
                }
                .padding()
            }
        }
    }
}

#Preview {
    PackingListView(trip: Trip.exampleTrip)
}


struct ListItemView: View {
    
    @Binding var item: Item
    
    var body: some View {
        HStack {
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
                Text(item.name)
                    .foregroundStyle(.accent)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            
            

//            Spacer()
            HStack(spacing: 35) {
                ListItemPackedButton(item: $item)
                ListItemWearingButton(item: $item)
                Text("x\(item.userQuantity)")
                    .font(.title)
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
            
            
            Image(isSingular ? "jacket_button" : item.isWearing ? "jacket_1" : "jacket_button")
                .resizable()
                .scaledToFill()
                .frame(width: 35, height: 35)
                .foregroundStyle(item.isWearing ? Color.accent : Color.primary.opacity(0.4))
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
