//
//  TripPlannerView.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//
import SwiftUI
import MapKit

struct TripPlannerView: View {
    @ObservedObject var viewModel = TripPlannerViewModel()
    
    @State var exampleBag: Bag = Bag(itemList: [
        Item.charger,
        Item.shoes,
        Item.socks,
        Item.tops
    ])
    
    @State private var isDestinationActive: Bool = false
    @State private var isDateActivated: Bool = false
    @FocusState private var isDestinationFocused: Bool

    let destinationPlaceholderText = "Naples, New York, Bangkok..."

    @State private var destinationText: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                
                        Text("How long for?")
                            .font(.title)
                Button {
                    
                        isDateActivated.toggle()
                } label: {
                        Text("When?")
                        .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(.gray, lineWidth: 1)
                            }
                }
                .popover(isPresented: $isDateActivated) {
                    MultiDatePickerView()
                        .presentationCompactAdaptation(.popover)
                }

                
                        Text("What are you doing?")
                            .font(.title)
                
                Spacer()
    
                Button("MAKE ME A BAG!") {
                    
                }.background {
                    
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.gray, lineWidth: 1)
                }
            }
            .padding()
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text("Search for a location")) {
                ForEach(viewModel.searchResults, id: \.self) { location in
                    Button("\(location.placemark.title ?? "")") {
                        destinationText = location.placemark.title ?? ""
                        withAnimation {
                            isDestinationActive.toggle()
                        }
                    }
                }
            }
            .searchPresentationToolbarBehavior(.avoidHidingContent)
            .textInputAutocapitalization(.sentences)
            .padding(.all, 8)
            .cornerRadius(8)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled(true)
            .focused($isDestinationFocused)
            .navigationTitle("Where are you going?")
        }
        .navigationDestination(isPresented: $viewModel.isBagGenerated, destination: {
            SwipeView(itemList: $viewModel.items)
        })
    }
}

#Preview {
    TripPlannerView()
}
