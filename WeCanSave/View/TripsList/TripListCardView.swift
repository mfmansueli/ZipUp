//
//  TripListCardView.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 12/03/25.
//

import SwiftUI

struct TripListCardView: View {
    
    @State var trip: Trip
    @State var isPast: Bool = false
    
    
    
    var body: some View {
        HStack {
            VStack {
                Text("\(shortDateString(trip.startDate))")
                    .fontWeight(.thin)
                    .font(.caption)
                RoundedRectangle(cornerRadius: 10)
                    .fill(.primary.opacity(0.5))
                    .frame(width: 1, height: 25)
                Text("\(shortDateString(trip.endDate))")
                    .fontWeight(.thin)
                    .font(.caption)
            }
            .padding()
            
            VStack(alignment: .leading) {
                Spacer()

                Text(trip.destinationName)
                    .font(.system(size: 40))
                    .fontWeight(.semibold)
                Text("(\(trip.duration) days)")
                    .fontWeight(.light)
                Spacer()

            }
//            .padding(.top, 10)
            Spacer()
            
            Image(systemName: "chevron.compact.right")
                .foregroundStyle(.primary.opacity(0.2))
                .padding()

        }
        .frame(height: 110)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.clear)
                .stroke(isPast ? Color.primary.opacity(0.5) : Color.accent, lineWidth: isPast ? 1 : 3)
        )
        .opacity(isPast ? 0.5 : 1)
//        .padding(.vertical, 10)
    }
    
    func shortDateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM")
        
        return dateFormatter.string(from: date)
        
    }
}

#Preview {
    TripListCardView(trip: Trip.exampleTrip)
}
#Preview {
    TripsListView()
}
