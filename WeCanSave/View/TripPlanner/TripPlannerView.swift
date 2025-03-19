//
//  TripPlannerView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//
import SwiftUI
import MapKit
import SwiftData

struct TripPlannerView: View {
    
    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel: TripPlannerViewModel
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var isDateActivated: Bool = false
    @FocusState private var isDestinationFocused: Bool
    
    init(modelContext: ModelContext, selectedTrip: Binding<Trip?>) {
        viewModel = TripPlannerViewModel(modelContext: modelContext, selectedTrip: selectedTrip)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                Divider()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Where are you going?")
                        .font(.title)
                    
                    TextField("", text: $viewModel.searchText)
                        .autocorrectionDisabled(true)
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                        .padding()
                        .placeholder(when: viewModel.searchText.isEmpty) {
                            Text("Naples, New York, Bangkok...")
                                .fontWeight(.light)
                                .tint(.primary)
                                .opacity(0.5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .onTapGesture {
                                    isDestinationFocused = true
                                }
                        }
                        .focused($isDestinationFocused)
                        .background {
                            RoundedRectangle(cornerRadius: 32)
                                .strokeBorder(Color.accentColor, lineWidth: 1)
                        }
                        .popover(isPresented: $viewModel.showAddressPopover) {
                            VStack {
                                ForEach(viewModel.searchResults, id: \.self) { item in
                                    Button {
                                        viewModel.selectedPlacemark = item.placemark
                                        isDestinationFocused = false
                                    } label: {
                                        Text("\(item.placemark.title ?? "")")
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .presentationCompactAdaptation(.popover)
                        }
                        .padding(.bottom, 16)
                    
                    Text("When are you going?")
                        .font(.title)
                    
                    Button {
                        isDateActivated.toggle()
                        print(viewModel.dates)
                    } label: {
                        HStack {
                            
                            if viewModel.dates.isEmpty {
                                Text("Pick your dates")
                                    .fontWeight(.light)
                                    .tint(.primary)
                                    .opacity(0.5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                Spacer()

                                Image(systemName: "calendar.badge.plus")
                                    .padding()
                                    .padding(.trailing, 5)
                                    .tint(.primary.mix(with: .secondary, by: 0.9))
                            } else {
                                Text("\(getShortTravelDates())–\(getShortTravelDates(isStart: false))")
                                    .font(.headline)
                                    .tint(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                
                                Spacer()

                                
                                Text(viewModel.dates.isEmpty ? "" : "\(viewModel.dates.count) days")
                                    .font(.headline)
                                    .tint(.primary)
                                    .padding()
                            }
                            
                            
                        }
                        .accessibilityAddTraits(.isSearchField)
                        .background {
                            RoundedRectangle(cornerRadius: 32)
                                .strokeBorder(Color.accentColor, lineWidth: 1)
                        }
                    }
                    .popover(isPresented: $isDateActivated) {
                        MultiDatePickerView(dates: Binding(get: {
                            viewModel.dates
                        }, set: { newDates in
                            viewModel.dates = newDates
                        }))
                        .presentationCompactAdaptation(.popover)
                        .tint(.accent)
                    }
                    .padding(.bottom, 16)
                    
                    Text("What are you doing?")
                        .font(.title)
                    
//                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                    VStack(spacing: 10) {
                        HStack(spacing: 20) {
                            ForEach(TripType.allCases.prefix(2), id: \.self) { item in
                                tripTypeButton(for: item)
                            }
                        }
                        
                        tripTypeButton(for: TripType.allCases[2])
                            .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 20) {
                            ForEach(TripType.allCases.suffix(2), id: \.self) { item in
                                tripTypeButton(for: item)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button("BUILD ME A BAG!") {
                            viewModel.loadBag()
                        }
                        .padding()
                        .padding(.horizontal, 20)
                        .foregroundStyle(.white)
                        .font(.headline)
                        .background {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.accentColor)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .padding(.all, 8)
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .applyLoading(viewModel: viewModel)
            .applyAlert(viewModel: viewModel)
//            .onChange(of: viewModel.tripCreatedSuccessfully) { newValue, arg in
//                if newValue {
//                    presentation.wrappedValue.dismiss()
//                    selectedTrip = viewModel.createdTrip
//                }
//            }
        }
    }
    
    func tripTypeButton(for item: TripType) -> some View {
        Button {
            viewModel.selectedTripType = item
        } label: {
            Label {
//                Text(item.title)
                Text(item.rawValue)
                    .font(.subheadline)
            } icon: {
                Image(item.image)
                    .resizable()
                    .scaledToFit()

                    .frame(width: 35, height: 24)
            }
            .fixedSize()
            .padding()
            .frame(width: 140)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(viewModel.selectedTripType == item ? Color.accentColor : Color.gray, lineWidth: viewModel.selectedTripType == item ? 2 : 1)
            }
        }
        .tint(viewModel.selectedTripType == item ? Color.accentColor : Color.gray)
    }
    
    func getShortTravelDates(isStart: Bool = true) -> String {
        let longDate: Date?
        
        if isStart {
            longDate = viewModel.dates.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).first?.date
        } else {
            longDate = viewModel.dates.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).last?.date
        }
    
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM")
        
        let shortDate = dateFormatter.string(from: longDate ?? .distantPast)
        return shortDate
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    TripPlannerView(modelContext: modelContext, selectedTrip: .constant(nil))
}
