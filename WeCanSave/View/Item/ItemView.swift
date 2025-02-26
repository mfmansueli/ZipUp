//
//  ItemView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI

struct ItemView: View {
    
    @State var item: Item
    @State private var offset = CGSize.zero
    var removal: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            
            ZStack {
                if let image = item.imageName {
                    Image(systemName: image)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                }
                Image(systemName: offset.width < 0 ? "xmark.circle" : "checkmark.circle")
                    .resizable()
                    .foregroundStyle(offset.width < 0 ? .red : .green)
                    .opacity(abs(offset.width) > 10 ? 1 : 0)
                    .frame(width: 140, height: 140)
            }
            
            
            Text("\(item.name)")
                .font(.largeTitle)
                .bold()
            
            
            HStack(spacing: 40) {
                
                Button {
                    item.decrementUserQuantity()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .stroke(.black, lineWidth: 6)
                            .frame(maxWidth: 60)
                        
                        Image(systemName: "minus")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }

                
                Text("\(item.userQuantity)")
                    .font(.system(size: 60, weight: .bold))
                
                
                Button {
                    item.incrementUserQuantity()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .stroke(.black, lineWidth: 6)
                            .frame(maxWidth: 60)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }
            }
            
            Text("Here is maybe where we could put our AI-based reasoning for why we picked this number for this item")
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(radius: 10)
        )
        .frame(width: 350, height: 500)
        .padding(40)
        .rotationEffect(.degrees(offset.width / 5.0))
        .offset(x: offset.width * 5)
        .opacity(2 - Double(abs(offset.width / 30)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation {
                        offset = gesture.translation
                    }
                }
                .onEnded { _ in
                    if abs(offset.width) > 60 {
                        removal?()
                    } else {
                        offset = .zero
                    }
                }
        )
    }
}

#Preview {
    ItemView(item: Item.charger)
}
