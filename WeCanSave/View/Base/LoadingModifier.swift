//
//  LoadingModifier.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 10/03/25.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    @ObservedObject var viewModel: BaseViewModel
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $viewModel.isLoading) {
                LoadingView()
                    .presentationBackgroundInteraction(.enabled)
                    .presentationBackground(.ultraThinMaterial)
            }
    }
}
