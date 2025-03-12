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
        GeometryReader { geometry in
            ZStack {
                if showProgress {
                    Circle()
                        .trim(from: 0, to: bagProgress)
                        .rotation(.degrees(-90))
                        .stroke(.brandGreen, style: StrokeStyle(lineWidth: geometry.size.width * 0.04, lineCap: .round))
                }
                
                ZStack(alignment: .bottomLeading) {
                    Image(isOpen ? "Bag_open-symbol"  : "Bag_closed-symbol")
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(.brandOrange)
//                                        .padding(80)
                    
                    Text("\(itemCount)")
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .padding(5)
                        .background(
                            Circle()
                                .fill(.background)
                                .stroke(.foreground, lineWidth: 2)
                        )
                        .offset(x: -geometry.size.width * 0.1)
                }
                .padding(showProgress ? geometry.size.width * 0.15 : 0)
                .padding(.leading)
                
                
            }
            .frame(maxWidth: geometry.size.width * 0.9)
//            .padding(geometry.size.width * 0.1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Bag builder progress: Suggestions remaining; 4")
        }
        
    }
}

#Preview {
    BagProgressView(bagProgress: 0.4, isOpen: false, showProgress: true, itemCount: 10)
}
