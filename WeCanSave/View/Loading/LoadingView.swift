//
//  LoadingView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 10/03/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var currentMessageIndex = 0
//    private let messages = [
//        "We are preparing your bag...",
//        "folding the clothes...",
//        "getting the best tips for your bag..."
//    ]
    
    private let messages = [
            String(localized: "We are preparing your bag..."),
            String(localized: "Folding the clothes..."),
            String(localized: "Getting the best tips for your bag...")
        ]
    var body: some View {
        VStack {
            Text(messages[currentMessageIndex])
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentMessageIndex = (currentMessageIndex + 1) % messages.count
                        }
                    }
                }
            
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
        }
    }
}

#Preview {
    LoadingView()
}
