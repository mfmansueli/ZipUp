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

                Image(item.imageName)
                        .resizable()
                        .scaledToFit()


                Image(systemName: offset.width < 0 ? "xmark.circle" : "checkmark.circle")
                    .resizable()
                    .foregroundStyle(offset.width < 0 ? .red : .green)
                    .opacity(abs(offset.width) > 10 ? 1 : 0)
                    .frame(width: 140, height: 140)
            }
            
            
            Text("\(item.name)")
                .font(.title)
                .bold()
            
            
            HStack(spacing: 40) {
                
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
                .fontWeight(.thin).italic()
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.brandOrange, lineWidth: 15)
                .fill(.brandTan)
                .shadow(radius: 5)
        )
        .frame(width: 320, height: 500)
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
                        
                        if offset.width > 0 {
                            //added to list
                            
                        } else {
                            item.userQuantity = 0
//                            print(item)
                        }
                        item.isDecided = true
                        removal?()
                        
                    } else {
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
