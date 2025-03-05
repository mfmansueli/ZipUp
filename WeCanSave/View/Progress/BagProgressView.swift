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
    @State var itemCount: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .trim(from: 0, to: bagProgress)
                    .rotation(.degrees(-90))
                    .stroke(.brandGreen, style: StrokeStyle(lineWidth: geometry.size.width * 0.04, lineCap: .round))
                
                ZStack(alignment: .bottomLeading) {
                    Image(isOpen ? "Bag_open-symbol"  : "Bag_closed-symbol")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.brandOrange)
                    //                    .padding(80)
                    
                    Text("\(itemCount)")
                    //                    .font(.title)
                        .foregroundStyle(.foreground)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(.background)
                                .stroke(.foreground, lineWidth: 2)
                        )
                }
                .padding(geometry.size.width * 0.15)
                .padding(.leading)
                
                
            }
//            .frame(maxWidth: geometry.size.width * 0.9)
//            .padding(geometry.size.width * 0.1)
        }
        
    }
}

#Preview {
    BagProgressView(bagProgress: 0.4, isOpen: false, itemCount: 10)
}
