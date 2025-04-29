//
//  BaseViewModel.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 10/03/25.
//

import Foundation
import SwiftUI

class BaseViewModel: ObservableObject {
    var alertMessage = ""
    var alertTitle = ""
    var buttons: [Button<Text>] = [Button("Cancel", role: .cancel) { }]
    @Published var showAlert = false
    @Published var isLoading: Bool = false
    
    func showAlert(title: String? = nil,
                   message: String?,
                   buttons: [Button<Text>] = [ Button("Cancel", role: .cancel) { } ]) {
        self.alertTitle = title ?? ""
        self.alertMessage = message ?? ""
        self.buttons = buttons
        self.showAlert = true
    }
}
