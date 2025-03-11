//
//  TripPlannerView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//
import SwiftUI
import MapKit

struct TripPlannerView: View {
    
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel = TripPlannerViewModel()
    
    @State var exampleBag: Bag = Bag(itemList: [
        Item.charger,
        Item.shoes,
        Item.socks,
        Item.tops
    ])
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var isDestinationActive: Bool = false
    @State private var isDateActivated: Bool = false
    @FocusState private var isDestinationFocused: Bool
    
    let destinationPlaceholderText = "Naples, New York, Bangkok..."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Where are you going?")
                .font(.title)
            
            TextField(destinationPlaceholderText, text: $viewModel.searchText)
                .multilineTextAlignment(.leading)
                .font(.headline)
                .padding()
                .textFieldStyle(.plain)
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
                                viewModel.showAddressPopover = false
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
                .background {
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(Color.accentColor, lineWidth: 1)
                }
            }
            .popover(isPresented: $isDateActivated) {
                MultiDatePickerView(dates: $viewModel.dates)
                    .presentationCompactAdaptation(.popover)
            }
            .padding(.bottom, 16)
            
            Text("What are you doing?")
                .font(.title)
            
            LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                ForEach(TripType.allCases, id: \.self) { item in
                    Button {
                        viewModel.selectedTripType = item
                    } label: {
                        Label(item.rawValue, image: item.image)
                            .font(.subheadline)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 32)
                                    .strokeBorder(viewModel.selectedTripType == item ? Color.accentColor : Color.gray, lineWidth: viewModel.selectedTripType == item ? 2 : 1)
                            }
                    }
                    .tint(viewModel.selectedTripType == item ? Color.accentColor : Color.gray)
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("MAKE ME A BAG!") {
                    viewModel.loadBag()
                }
                .padding()
                .foregroundStyle(.background)
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
        .applyAlert(viewModel: viewModel)
        .applyLoading(viewModel: viewModel)
        .onAppear {
            viewModel.modelContext = modelContext
        }
    }
}

#Preview {
    TripPlannerView()
}
