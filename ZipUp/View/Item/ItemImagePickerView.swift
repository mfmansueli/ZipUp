//
//  ItemImagePickerView.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 19/03/25.
//

import SwiftUI

struct ItemImagePickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: String
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(ItemImage.allCases, id: \.self) { item in
                    Button {
                        selectedImage = item.rawValue
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(item.rawValue)
                            .resizable()
                            .scaledToFit()
                            .padding(4)
                            .background {
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(.clear)
                                    .stroke(Color.primary, lineWidth: 1)
                            }
                    }
                }
            }.padding()
        }
    }
}

#Preview {
    ItemImagePickerView(selectedImage: .constant(ItemImage.belt.rawValue))
}
