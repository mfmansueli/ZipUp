//
//  View+Extension.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 10/03/25.
//


import SwiftUI

extension View {
    func applyAlert(viewModel: BaseViewModel) -> some View {
        self.modifier(AlertModifier(viewModel: viewModel))
    }
    
    func applyLoading(viewModel: BaseViewModel) -> some View {
        self.modifier(LoadingModifier(viewModel: viewModel))
    }
    
    func placeholder<Content: View>(when shouldShow: Bool,
                                    alignment: Alignment = .leading,
                                    @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
