//
//  Data.swift
//  WeCanSave
//
//  Created by Mathew Blanc on 24/02/25.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit

struct User: Identifiable {
    var id = UUID()
    var trips: [Trip]
}

struct Trip: Identifiable {
    var id = UUID()
//    let destinationID: UUID
    let destinationName: String
    let destinationLatLong: CLLocationCoordinate2D
    let destinationLat: String
    let destinationLong: String
    var startDate: Date
    var endDate: Date
    var duration: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }
    var category: String
    var bag: Bag
    var isFinished = false
    
    static let exampleTrip = Trip(
        destinationName: "Dublin",
        destinationLatLong: CLLocationCoordinate2D(latitude: 53.34570, longitude: -6.268386),
        destinationLat: "53.34570",
        destinationLong: "-6.268386",
        startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!,
        endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 18))!,
        category: "Adventure",
        bag: Bag.exampleBag
    )
}

struct Bag: Identifiable {
    var id = UUID()
    var itemList = [BagItem]()
    
    static let exampleBag = Bag(itemList: [
        BagItem.socks,
        BagItem.tops,
        BagItem.shoes,
        BagItem.charger,
    ])
}

struct BagItem: Identifiable {
    var id = UUID()
    let name: String
    let category: String
    var userQuantity: Int
    let AIQuantity: Int
    var imageName: String?
    var isPair = false
    
    static let socks = BagItem(name: "Socks", category: "Clothes", userQuantity: 4, AIQuantity: 4, isPair: true)
    static let tops = BagItem(name: "Tops", category: "Clothes", userQuantity: 6, AIQuantity: 6)
    static let shoes = BagItem(name: "Shoes", category: "Shoes", userQuantity: 2, AIQuantity: 2, isPair: true)
    static let charger = BagItem(name: "Charger", category: "Electronics", userQuantity: 1, AIQuantity: 1)
}





