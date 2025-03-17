//
//  ItemView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI

struct ItemView: View {
    
    @Binding var item: Item
    @State private var offset = CGSize.zero
    var removal: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFit()
                
                Image(systemName: offset.width < 0 ? "xmark.circle" : "checkmark.circle")
                    .resizable()
                    .foregroundStyle(offset.width < 0 ? .red : .green)
                    .opacity(abs(offset.width) > 10 ? 0.7 : 0)
                    .frame(width: 140, height: 140)
                
                Text(offset.width < 0 ? "Remove from bag" : "Add to bag")
                    .foregroundStyle(offset.width < 0 ? .red : .green)
                    .opacity(abs(offset.width) > 10 ? 1 : 0)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .shadow(radius: 10)
                            .opacity(abs(offset.width) > 10 ? 1 : 0)
                    )
                    .rotationEffect(.degrees(-(offset.width / 5.0)))
                    .offset(x: -(offset.width * 5 + 20), y: -160 + abs(offset.width / 2))
            }
            
            
            Text("\(item.name)")
                .font(.title)
                .bold()
                .foregroundStyle(.black)
            
            
            HStack(spacing: 30) {
                
                Button {
                    item.decrementUserQuantity()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.clear)
                            .stroke(.brandOrange, lineWidth: 4)
                            .frame(maxWidth: 60)
                        
                        Image(systemName: "minus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.brandOrange)
                    }
                }
                
                
                Text("\(item.userQuantity)")
                    .font(.system(size: 50, weight: .bold))
                    .minimumScaleFactor(0.01)
                    .foregroundStyle(.black)
                
                
                Button {
                    item.incrementUserQuantity()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.clear)
                            .stroke(.brandOrange, lineWidth: 4)
                            .frame(maxWidth: 60)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.brandOrange)
                    }
                }
            }
            
            Text("Here is maybe where we could put our AI-based reasoning for why we picked this number for this item")
                .foregroundStyle(.black)
                .fontWeight(.thin).italic()
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.brandOrange, lineWidth: 15)
                .fill(.brandTan)
                .shadow(radius: 5)
        )
        .frame(width: 300, height: 450)
        .rotationEffect(.degrees(offset.width / 5.0))
        .offset(x: offset.width * 5)
        .opacity(2 - Double(abs(offset.width / 30)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation {
                        offset = CGSize(width: gesture.translation.width / 4,
                                        height: gesture.translation.height / 4)
                    }
                }
                .onEnded { _ in
                    if abs(offset.width) > 60 {
                        item.isDecided = true
                        if offset.width > 0 {
                            // added to list
                            return
                        }
                        item.userQuantity = 0
                        removal?()
                        return
                    }
                    withAnimation {
                        offset = .zero
                    }
                }
        )
        .accessibilityRepresentation {
            Text("Suggestion: \(item.name). Number to bring: \(item.userQuantity)")
        }
        .accessibilityAction(named: "Add to bag", {
            item.isDecided = true
            removal?()
        })
        .accessibilityAction(named: "Discard from bag", {
            item.userQuantity = 0
            item.isDecided = true
            removal?()
        })
        .accessibilityAction(named: "Increase number of \(item.name)") {
            item.incrementUserQuantity()
            let editedAnnouncement = AttributedString("\(item.userQuantity) \(item.name)s")
            AccessibilityNotification.Announcement(editedAnnouncement).post()
        }
        .accessibilityAction(named: "Decrease number of \(item.name)") {
            item.decrementUserQuantity()
            let editedAnnouncement = AttributedString("\(item.userQuantity) \(item.name)s")
            AccessibilityNotification.Announcement(editedAnnouncement).post()
        }
    }
}

#Preview {
    ItemView(item: .constant(Item.socks))
}
