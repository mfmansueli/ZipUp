//
//  PackingListView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI

struct PackingListView: View {
    
    @State var trip: Trip?
    
    @State private var bagBuilderShowing: Bool
    
    //    @State private var addItemSheetShowing: Bool = false
    
    var itemCount: Int {
        trip?.getItemCount() ?? 0
    }
    
    init(trip: Trip?) {
        self.trip = trip
        self.bagBuilderShowing = true //!trip.bag!.isDecided
    }
    
    var body: some View {
        if let trip = trip {
            NavigationStack {
                GeometryReader { geometry in
                    VStack(alignment: .leading) {
                        HStack {
                            WeatherView2(trip: trip)
                                .frame(width: geometry.size.width * 0.65 - 20)
                            
                            Divider()
                                .frame(width: 1, height: 100)
                                .padding(.trailing, 20)
                            
                            BagProgressView(bagProgress: 1, isOpen: true, showProgress: true, itemCount: itemCount)
                                .frame(width: geometry.size.width * 0.35 - 40)
                            
                        }
                        .frame(height: 100)
                        .padding(.bottom, 20)
                        
                        Text("Your bag")
                            .font(.title).bold()
                        
                        let groupedItems = Dictionary(grouping: trip.itemList, by: { $0.category })
                        
                        List {
                            ForEach(groupedItems.keys.sorted(), id: \.self) { category in
                                Section(
                                    header: HStack {
                                        Text(category).font(.title3).bold()
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
                }
                .navigationTitle(trip.destinationName + " (\(trip.duration) days)")
                .navigationBarTitleDisplayMode(.inline)
            }
            
        } else {
            ContentUnavailableView {
                Label("No Trip Selected", systemImage: "exclamationmark.triangle.fill")
            } description: {
                Text("Please select a trip to view the packing list.")
            }
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

struct SectionView: View {
    @State var trip: Trip
    var filteredItems: [Item] = []
    
    init(trip: Trip, category: String) {
        self.trip = trip
        filteredItems = trip.itemList.filter { $0.category == category }
    }
    
    var body: some View {
        ForEach(filteredItems.indices, id: \.self) { index in
            let item = $trip.itemList.first(where: { $0.id == filteredItems[index].id })!
            
            ListItemView(item: item)
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
            
        }
        HStack {
            Button("Add item") {
                //
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
