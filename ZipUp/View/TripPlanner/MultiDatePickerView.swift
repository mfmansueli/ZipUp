//
//  MultiDatePickerView.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 08/03/25.
//

import SwiftUI

struct MultiDatePickerView: View {
    
    @Environment(\.presentationMode) var presentation
    @Environment(\.calendar) var calendar
    @Environment(\.timeZone) var timeZone
    @Binding var dates: Set<DateComponents>
    let datePickerComponents: Set<Calendar.Component> = [.calendar, .era, .year, .month, .day]
    
    var today: Date {
        calendar.startOfDay(for: Date())
    }
    
    var bounds: Range<Date> {
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(from: DateComponents(
            timeZone: timeZone, year: 2100, month: 1, day: 1))!
        return start ..< end
    }
    
    var datesBinding: Binding<Set<DateComponents>> {
        Binding {
            dates
        } set: { newValue in
            if newValue.isEmpty {
                dates = newValue
            } else if newValue.count > dates.count {
                if newValue.count == 1 {
                    dates = newValue
                } else if newValue.count == 2 {
                    dates = filledRange(selectedDates: newValue)
                } else if let firstMissingDate = newValue.subtracting(dates).first {
                    dates = [firstMissingDate]
                } else {
                    dates = []
                }
            } else if let firstMissingDate = dates.subtracting(newValue).first {
                dates = [firstMissingDate]
            } else {
                dates = []
            }
        }
    }
    
    var body: some View {
        VStack {
            MultiDatePicker("Select dates",
                            selection: datesBinding,
                            in: bounds)
            
            HStack {
                Button(action: {
                    dates.removeAll()
                    presentation.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .foregroundStyle(.primary)
                
                Button(action: {
                    presentation.wrappedValue.dismiss()
                }) {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerSize: CGSize(width: 32, height: 32)))
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
        }
    }
    
    private func filledRange(selectedDates: Set<DateComponents>) -> Set<DateComponents> {
        let allDates = selectedDates.compactMap { calendar.date(from: $0) }
        let sortedDates = allDates.sorted()
        var datesToAdd = [DateComponents]()
        if let first = sortedDates.first, let last = sortedDates.last {
            var date = first
            while date < last {
                if let nextDate = calendar.date(byAdding: .day, value: 1, to: date) {
                    if !sortedDates.contains(nextDate) {
                        let dateComponents = calendar.dateComponents(datePickerComponents, from: nextDate)
                        datesToAdd.append(dateComponents)
                    }
                    date = nextDate
                } else {
                    break
                }
            }
        }
        return selectedDates.union(datesToAdd)
    }
}

#Preview {
    MultiDatePickerView(dates: .constant([]))
}
