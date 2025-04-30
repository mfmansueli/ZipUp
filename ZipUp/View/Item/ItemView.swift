//
//  ItemView.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 24/02/25.
//
import SwiftUI
import UIKit

struct ItemView: View {
//    var item: Item?
    @State private var draftItem: DraftItem
//    { didSet { draftItem.updateItem(item) } }
    @State private var offset = CGSize.zero
    @Binding private var isEditMode: Bool
    @State private var showImagePicker = false
    var removal: ((DraftItem) -> Void)
    var added: ((DraftItem) -> Void)
    @State var isAnimationRunning = false
    @State var increaseFeedback = false
    @State var decreaseFeedback = false
    @State var deniedFeedback = false
    @State var selectionFeedback = false

    init(item: Item?,
         isEditMode: Binding<Bool>,
         category: ItemCategory,
         removal: @escaping ((DraftItem) -> Void),
         added: @escaping ((DraftItem) -> Void)) {
        self.removal = removal
        self.added = added
        
        if let value = item {
            self._draftItem = State(initialValue: DraftItem(from: value))
        } else {
            self._draftItem = State(initialValue: DraftItem(category: category))
        }
        _isEditMode = isEditMode
    }

    var body: some View {
        
        ZStack {
            HStack {
                Image(systemName: "xmark")
                    .foregroundStyle(.red.opacity(0.4))
                    .padding(.leading, 6)
                
                Spacer()
                
                Image(systemName: "checkmark")
                    .foregroundStyle(.green.opacity(0.4))
                    .padding(.trailing, 6)
            }
            .font(.title2)
            .offset(y: 50)
            VStack(spacing: 30) {
                ZStack {
                    Button {
                        showImagePicker = true
                    } label: {
                        Image(uiImage: draftItem.image)
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
                        ItemImagePickerView(selectedImage: $draftItem.imageName)
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
                TextField("", text: $draftItem.name)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.black)
                    .disabled(!isEditMode)
                    .submitLabel(.done)
                    .placeholder(when: draftItem.name.isEmpty, alignment: .center) {
                        Text("Item name")
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .foregroundColor(Color.black.opacity(0.2))
                    }
                
                HStack(spacing: 30) {
                    Button {
                        if draftItem.userQuantity == 1 {
                            deniedFeedback.toggle()
                            return
                        }
                        draftItem.userQuantity -= 1
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
                    
                    Text("\(draftItem.userQuantity)")
                        .font(.system(size: 50, weight: .bold))
                        .minimumScaleFactor(0.01)
                        .foregroundStyle(.black)
                    
                    Button {
                        draftItem.userQuantity += 1
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
                
                Text(draftItem.tipReason)
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
            .gesture(swipeGesture())
            //        TODO: Add accessibility
            //        .accessibilityRepresentation {
            //            Text("Suggestion: \(draftItem.name). Number to bring: \(draftItem.userQuantity)")
            //        }
            //        .accessibilityAction(named: "Add to bag", {
            //            draftItem.isDecided = true
            //            added(draftItem)
            //        })
            //        .accessibilityAction(named: "Discard from bag", {
            //            draftItem.userQuantity = 0
            //            draftItem.isDecided = true
            //            removal(draftItem)
            //        })
            //        .accessibilityAction(named: "Increase number of \(draftItem.name)") {
            //            draftItem.incrementUserQuantity()
            //            let editedAnnouncement = AttributedString("\(draftItem.userQuantity) \(draftItem.name)s")
            //            AccessibilityNotification.Announcement(editedAnnouncement).post()
            //        }
            //        .accessibilityAction(named: "Decrease number of \(draftItem.name)") {
            //            draftItem.decrementUserQuantity()
            //            let editedAnnouncement = AttributedString("\(draftItem.userQuantity) \(draftItem.name)s")
            //            AccessibilityNotification.Announcement(editedAnnouncement).post()
            //        }
            .sensoryFeedback(.increase, trigger: increaseFeedback)
            .sensoryFeedback(.decrease, trigger: decreaseFeedback)
            .sensoryFeedback(.warning, trigger: deniedFeedback)
            .sensoryFeedback(.selection, trigger: selectionFeedback)
        }
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
                    draftItem.isDecided = true
                    selectionFeedback.toggle()
                    if offset.width > 0 {
                        added(draftItem)
                        return
                    }
                    draftItem.userQuantity = 0
                    removal(draftItem)
                    return
                }
                withAnimation {
                    offset = .zero
                }
            }
    }
}

#Preview {
    ItemView(item: Item.socks, isEditMode: .constant(true), category: .clothing, removal: { _ in }, added: { _ in })
}
