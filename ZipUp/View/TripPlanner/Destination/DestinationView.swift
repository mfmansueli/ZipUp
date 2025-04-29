//
//  DestinationView.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 17/03/25.
//
import SwiftUI
import MapKit

struct DestinationView: View {
    @StateObject var viewModel: DestinationViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(viewModel.searchResults, id: \.self) { item in
                    Button {
                        viewModel.selectedPlacemark = item.placemark
                    } label: {
                        
                        Text(item.placemark.itemName())
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.primary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(uiColor: .tertiarySystemBackground))
                .clipShape(
                    .rect(
                        topLeadingRadius: 4,
                        bottomLeadingRadius: 16,
                        bottomTrailingRadius: 16,
                        topTrailingRadius: 4
                    )
                )
        }
        .padding(.top, -1)
        .padding(.horizontal, 16)
        .transition(.slide)
        .animation(.easeInOut, value: viewModel.searchResults)
    }
}

#Preview {
    @Previewable @StateObject var viewModel: DestinationViewModel = DestinationViewModel()
    DestinationView(viewModel: viewModel)
}
