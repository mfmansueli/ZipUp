//
//  BagProgressView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 03/03/25.
//

import SwiftUI

struct BagProgressView: View {
    
    @State var bagProgress: Double
    @State var isOpen: Bool
    @State var showProgress: Bool
    @State var itemCount: Int = 0
    
    var body: some View {
//
//        let badgeView = Text("\(itemCount)")
//                    .monospacedDigit()
//                    .bold()
//        
//        List {
//            Image(isOpen ? "Bag_open-symbol"  : "Bag_closed-symbol")
//                .resizable()
//                .scaledToFit()
//                .foregroundStyle(.brandOrange)
//                .padding(32)
//                .badge(badgeView)
//                .badgeProminence(.increased)
//        }
//        
//        .listStyle(.plain)
            ZStack {
//                
//                ZStack(alignment: .bottomLeading) {
//                    
//                    Text("\(itemCount)")
//                        .font(.caption)
//                        .foregroundStyle(.primary)
//                        .padding(5)
//                        .background(
//                            Circle()
//                                .fill(.background)
//                                .stroke(.foreground, lineWidth: 2)
//                        )
////                        .offset(x: -geometry.size.width * 0.1)
//                }
                
//                    if showProgress {
                        Circle()
                            .trim(from: 0, to: bagProgress)
                            .rotation(.degrees(-90))
                            .stroke(.brandGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .background {
                                    Image(isOpen ? "Bag_open-symbol"  : "Bag_closed-symbol")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.brandOrange)
                                        .padding(16)
                            }
//                    }
                
                
            }
//            .frame(maxWidth: geometry.size.width * 0.9)
//            .padding(geometry.size.width * 0.1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Bag builder progress: Suggestions remaining; 4")
        
    }
}

#Preview {
    BagProgressView(bagProgress: 0.8, isOpen: false, showProgress: true, itemCount: 10)
}

#Preview {
    PackingListView(trip: Trip.exampleTripDecided)
}
