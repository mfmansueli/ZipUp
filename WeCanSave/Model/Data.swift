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

struct User: Identifiable, Codable {
    var id = UUID()
    var trips: [Trip]
    
    enum CodingKeys: String, CodingKey {
        case id, trips
    }
    
}

struct Trip: Identifiable, Codable {
    var id = UUID()
    //    let destinationID: UUID
    let destinationName: String
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
    
    enum CodingKeys: String, CodingKey {
        case id, destinationName, destinationLat, destinationLong, startDate, endDate, category, bag, isFinished
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

struct Bag: Identifiable, Codable {
    var id = UUID()
    var itemList = [Item]()
    
    enum CodingKeys: String, CodingKey {
        case id, itemList
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
    var quantity: Int
    let AIQuantity: Int
    var imageName: String?
    var isPair = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, userQuantity, AIQuantity, imageName, isPair
    }
    
    static let socks = Item(name: "Socks", category: "Clothes", userQuantity: 4, AIQuantity: 4, isPair: true)
    static let tops = Item(name: "Tops", category: "Clothes", userQuantity: 6, AIQuantity: 6)
    static let shoes = Item(name: "Shoes", category: "Shoes", userQuantity: 2, AIQuantity: 2, isPair: true)
    static let charger = Item(name: "Charger", category: "Electronics", userQuantity: 1, AIQuantity: 1)
    
    mutating func incrementUserQuantity() {
        self.userQuantity += 1
    }
    
    mutating func decrementUserQuantity() {
        if self.userQuantity > 1 {
            self.userQuantity -= 1
        }
    }
    
}
