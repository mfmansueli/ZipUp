//
//  ItemView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import SwiftUI
import UIKit

struct ItemView: View {
    @Binding var item: Item
    @State private var offset = CGSize.zero
    @State private var isEditMode = false
    @State private var showImagePicker = false
    var removal: (() -> Void)? = nil
    var added: (() -> Void)? = nil
    @State var isAnimationRunning = false
    @State var increaseFeedback = false
    @State var decreaseFeedback = false
    @State var deniedFeedback = false
    @State var selectionFeedback = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Button {
                    showImagePicker = true
                } label: {
                    Image(uiImage: item.image)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            if isEditMode {
                                HStack {
                                    Spacer()
                                    VStack {
                                        Image(systemName: "photo.badge.plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .padding(10)
                                            .background {
                                                RoundedRectangle(cornerRadius: 30)
                                                    .fill(.white)
                                            }
                                        Spacer()
                                    }
                                }
                            }
                        }
                }
                .disabled(!isEditMode)
                .popover(isPresented: $showImagePicker) {
                    ItemImagePickerView(selectedImage: $item.imageName)
                        .presentationCompactAdaptation(.popover)
                }
                
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
                            .shadow(color: .black, radius: 10)
                            .opacity(abs(offset.width) > 10 ? 1 : 0)
                    )
                    .rotationEffect(.degrees(-(offset.width / 5.0)))
                    .offset(x: -(offset.width * 5 + 20), y: -160 + abs(offset.width / 2))
            }
            
            TextField("Item name", text: $item.name)
                .multilineTextAlignment(.center)
                .font(.title)
                .bold()
                .foregroundStyle(.black)
                .disabled(!isEditMode)
            
            HStack(spacing: 30) {
                Button {
                    if item.userQuantity == 1 {
                        deniedFeedback.toggle()
                        return
                    }
                    item.decrementUserQuantity()
                    decreaseFeedback.toggle()
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
                    increaseFeedback.toggle()
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
            
            Text(item.tipReason)
                .foregroundStyle(.black)
                .fontWeight(.thin).italic()
                .multilineTextAlignment(.center)
        }
        .scrollDismissesKeyboard(.immediately)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.brandOrange, lineWidth: 15)
                .fill(.brandTan)
                .shadow(color: .primary.opacity(0.1), radius: 5)
        )
        .frame(width: 300, height: 450)
        .rotationEffect(.degrees(offset.width / 5.0))
        .offset(x: offset.width * 5)
        .opacity(2 - Double(abs(offset.width / 30)))
        .gesture(
            swipeGesture()
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditMode ? "Done" : "Edit") {
                    isEditMode.toggle()
                }
            }
        }
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
        .sensoryFeedback(.increase, trigger: increaseFeedback)
        .sensoryFeedback(.decrease, trigger: decreaseFeedback)
        .sensoryFeedback(.warning, trigger: deniedFeedback)
        .sensoryFeedback(.selection, trigger: selectionFeedback)
    }
    
    func swipeGesture() -> some Gesture {
        return DragGesture()
            .onChanged { gesture in
                if isEditMode {
                    if !isAnimationRunning {
                        withAnimation {
                            isAnimationRunning = true
                            offset = CGSize(width: 10, height: 0)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    offset = CGSize(width: -10, height: 0)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        offset = CGSize(width: 10, height: 0)
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            offset = CGSize(width: -10, height: 0)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation {
                                                offset = .zero
                                                isAnimationRunning = false
                                                deniedFeedback.toggle()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    withAnimation {
                        offset = CGSize(width: gesture.translation.width / 2,
                                        height: gesture.translation.height / 2)
                    }
                }
            }
            .onEnded { _ in
                if abs(offset.width) > 60 {
                    item.isDecided = true
                    selectionFeedback.toggle()
                    if offset.width > 0 {
                        added?()
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
    }
}

#Preview {
    ItemView(item: .constant(Item.socks))
}
