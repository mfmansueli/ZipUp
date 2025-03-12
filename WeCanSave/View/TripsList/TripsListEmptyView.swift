//
//  TripsListEmptyView.swift
//  WeCanSave
//
//  Created by cinzia ferrara on 12/03/25.
//

import SwiftUI

struct TripsListEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Group {
                Text("Where")
                    .foregroundColor(.brandOrange) +
                Text(" are you going next?")
            }
            .font(.system(size: 45, weight: .bold))
            .multilineTextAlignment(.center)
            
            Text("\nCreate your first trip to get started.")
            
            Image("PlanePath")
                .scaledToFit()
                .padding(.top, 20)
        }
    }
}

#Preview {
    TripsListEmptyView()
}
