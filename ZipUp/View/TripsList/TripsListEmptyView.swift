//
//  TripsListEmptyView.swift
//  ZipUp
//
//  Created by cinzia ferrara on 12/03/25.
//

import SwiftUI

struct TripsListEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Group {
                Text("Where")
                    .foregroundColor(.brandOrange) +
                Text(" are you going next?")
            }
            .font(.system(size: 45, weight: .bold))
            .multilineTextAlignment(.leading)
            
            Text("\nCreate your first trip to get started.")
                .font(.title3)
            
            Image("PlanePath")
                .scaledToFit()
                .padding(.top, 20)
        }
    }
}

#Preview {
    TripsListEmptyView()
}
