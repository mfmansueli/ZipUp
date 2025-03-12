//
//  AlertModifier.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 10/03/25.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    @ObservedObject var viewModel: BaseViewModel
    
    func body(content: Content) -> some View {
        content
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert, actions: {
                ForEach(viewModel.buttons.indices, id: \.self) { index in
                    viewModel.buttons[index]
                }
            }, message: {
                Text(viewModel.alertMessage)
            })
    }
}
