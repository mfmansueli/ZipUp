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


@Model
class Trip {
    var id = UUID()
    //    let destinationID: UUID
    var destinationName: String = ""
    var destinationLat: String = ""
    var destinationLong: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var duration: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) + 1
    }
    var category: String = ""
    
//    @Relationship(deleteRule: .cascade, inverse: \Bag.trip)
    var bag: Bag!
    var isFinished = false
//    
//    enum CodingKeys: String, CodingKey {
//        case id, destinationName, destinationLat, destinationLong, startDate, endDate, category, bag, isFinished
//    }
    
    init(destinationName: String, destinationLat: String, destinationLong: String, startDate: Date, endDate: Date, category: String, bag: Bag? = Bag.exampleBag, isFinished: Bool = false) {
        self.destinationName = destinationName
        self.destinationLat = destinationLat
        self.destinationLong = destinationLong
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.bag = bag
        self.isFinished = isFinished
    }
    
    static let exampleTrip = Trip(
        destinationName: "Dublin",
        //        destinationLatLong: CLLocationCoordinate2D(latitude: 53.34570, longitude: -6.268386),
        destinationLat: "53.34570",
        destinationLong: "-6.268386",
        startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!,
        endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 18))!,
        category: "Adventure",
        bag: Bag.exampleBag
    )
}

@Model
class Bag {
    var id = UUID()
    var itemList = [Item]()
    
//    @Relationship(inverse: \Trip.bag)
    var trip: Trip?
//    enum CodingKeys: String, CodingKey {
//        case id, itemList
//    }
    
    var isDecided: Bool = false
    
    init(id: UUID = UUID(), itemList: [Item] = [Item]()) {
        self.id = id
        self.itemList = itemList
    }
    
    static let exampleBag = Bag(itemList: [
        Item.socks,
        Item.tops,
        Item.shoes,
        Item.charger,
    ])
}

struct Item: Identifiable, Codable {
    var id = UUID()
    let name: String
    let category: String
    var userQuantity: Int
    let AIQuantity: Int
    var isDecided: Bool = false
    var imageName: String?
    var isPair = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, userQuantity, AIQuantity, isDecided, imageName, isPair
    }
    
    static let socks = Item(name: "Socks", category: "Clothes", userQuantity: 4, AIQuantity: 4, isPair: true)
    static let tops = Item(name: "Tops", category: "Clothes", userQuantity: 6, AIQuantity: 6)
    static let shoes = Item(name: "Shoes", category: "Shoes", userQuantity: 2, AIQuantity: 2, isPair: true)
    static let charger = Item(name: "Charger", category: "Electronics", userQuantity: 1, AIQuantity: 1, imageName: "Charger.png")
    
    mutating func incrementUserQuantity() {
        self.userQuantity += 1
    }
    
    mutating func decrementUserQuantity() {
        if self.userQuantity > 1 {
            self.userQuantity -= 1
        }
    }
    
}
