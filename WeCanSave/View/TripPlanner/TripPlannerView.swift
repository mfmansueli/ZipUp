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
    @FocusState private var isDestinationFocused: Bool

    let destinationPlaceholderText = "Naples, New York, Bangkok..."

    @State private var destinationText: String?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Where are you going?")
                    .font(.title)

                if isDestinationActive {
                    TextField(destinationPlaceholderText, text: $viewModel.searchText)
                        .padding(.all, 8)
                        .cornerRadius(8)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                        .focused($isDestinationFocused)

                    List(viewModel.searchResults, id: \.self) { location in
                        Button("\(location.placemark.title ?? "")") {

                            destinationText = location.placemark.title ?? ""

                            withAnimation {
                                isDestinationActive.toggle()
                            }

                        }

    //                    NavigationLink(destination: {
    ////                        SwipeView(itemList: $exampleBag.itemList)
    ////                        BagBuilderView(itemList: exampleBag.itemList)
    //                    }, label: {
    //                        Text(item.placemark.title ?? "")
    //                    })
                        //                Button(action: {
                        //                    viewModel.selectedItem = item
                        //                    viewModel.fetchWeather(for: item.placemark.coordinate)
                        //                }) {
                        //                    Text(item.placemark.title ?? "")
                        //                }

                    }
                    .listStyle(.plain)


                } else {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.background)
                            .frame(height: 50)
                            .shadow(radius: 4)
                            .onTapGesture {
                                isDestinationActive = true
                                isDestinationFocused.toggle()
                            }
                        Text(destinationText == nil ? destinationPlaceholderText : destinationText!)
                            .foregroundStyle(.foreground.opacity(destinationText == nil ? 0.4 : 1))
                            .padding()
                    }
                    .accessibilityAddTraits(.isSearchField)


                }


                if let weatherInfo = viewModel.weatherInfo {
                    Text(weatherInfo)
                        .padding()
                }

                Spacer()

                HStack {
                    Spacer()


//                    Button("Zip up my bag!") {
//
//                    }
//                    .buttonStyle(.borderedProminent)

                    NavigationLink("Zip up my bag!", destination: PackingListView(trip: Trip.exampleTrip))
                        .buttonStyle(.borderedProminent)

                    Spacer()

                }
            }
            .padding()
        }
        .navigationDestination(isPresented: $viewModel.isBagGenerated, destination: {
            SwipeView(itemList: $viewModel.items)
        })

    }
}

#Preview {
    TripPlannerView()
}
