//
//  DestinationView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 17/03/25.
//

import SwiftUI

struct DestinationView: View {
    @StateObject var viewModel: TripPlannerViewModel
    var animationNamespace: Namespace.ID
    
    var body: some View {
        VStack {
            TextField("", text: $viewModel.searchText)
                .multilineTextAlignment(.leading)
                .font(.headline)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(Color.accentColor, lineWidth: 1)
                }
                .matchedGeometryEffect(id: "searchTextField", in: animationNamespace)
                .padding(.bottom, 16)
            
            // Other UI elements...
        }
        .padding()
    }
}
