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
    
    init(modelContext: ModelContext) {
        viewModel = TripPlannerViewModel(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                Divider()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Where are you going?")
                        .font(.title)
                    
                    TextField("", text: $viewModel.searchText)
                        .multilineTextAlignment(.leading)
                        .font(.headline)
                        .padding()
                        .placeholder(when: viewModel.searchText.isEmpty) {
                            Text("Naples, New York, Bangkok...")
                                .font(.headline)
                                .tint(.primary)
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
                    
                    Text("How long for?")
                        .font(.title)
                    
                    Button {
                        isDateActivated.toggle()
                    } label: {
                        HStack {
                            Text("When?")
                                .font(.headline)
                                .tint(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            
                            Text(viewModel.dates.isEmpty ? "" : "\(viewModel.dates.count) days")
                                .font(.headline)
                                .tint(.primary)
                                .padding()
                            
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
                    }
                    .padding(.bottom, 16)
                    
                    Text("What are you doing?")
                        .font(.title)
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        ForEach(TripType.allCases, id: \.self) { item in
                            tripTypeButton(for: item)
                        }
                    }
                    
                    Spacer()
                    
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button("MAKE ME A BAG!") {
                            viewModel.loadBag()
                        }
                        .padding()
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
            .applyAlert(viewModel: viewModel)
            .applyLoading(viewModel: viewModel)
            .onChange(of: viewModel.tripCreatedSuccessfully) { newValue, arg in
                if newValue {
                    presentation.wrappedValue.dismiss()
                }
            }
        }
    }
    
    func tripTypeButton(for item: TripType) -> some View {
        Button {
            viewModel.selectedTripType = item
        } label: {
            Label {
                Text(item.rawValue)
                    .font(.subheadline)
            } icon: {
                Image(item.image)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 35, height: 24)
            }
            .fixedSize()
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(viewModel.selectedTripType == item ? Color.accentColor : Color.gray, lineWidth: viewModel.selectedTripType == item ? 2 : 1)
            }
        }
        .tint(viewModel.selectedTripType == item ? Color.accentColor : Color.gray)
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    TripPlannerView(modelContext: modelContext)
}
