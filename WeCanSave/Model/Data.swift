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
import CloudKit

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
    var itemList: [Item] = []
    var category: String = ""

//    @Relationship(deleteRule: .cascade, inverse: \Bag.trip)
//    var bag: Bag!
    var isFinished = false
//
//    enum CodingKeys: String, CodingKey {
//        case id, destinationName, destinationLat, destinationLong, startDate, endDate, category, bag, isFinished
//    }

    init(destinationName: String, destinationLat: String, destinationLong: String, startDate: Date, endDate: Date, category: String, itemList: [Item] = [
        Item.socks,
        Item.tops,
        Item.shoes,
        Item.charger,
    ], isFinished: Bool = false) {
        self.destinationName = destinationName
        self.destinationLat = destinationLat
        self.destinationLong = destinationLong
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.itemList = itemList
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
        itemList: [
            Item.socks,
            Item.tops,
            Item.shoes,
            Item.charger,
        ]
    )
    
    func toCKRecord() -> CKRecord {
        let tripRecord = CKRecord(recordType: "Trip")
        tripRecord["destinationName"] = destinationName as CKRecordValue
        tripRecord["destinationLat"] = destinationLat as CKRecordValue
        tripRecord["destinationLong"] = destinationLong as CKRecordValue
        tripRecord["startDate"] = startDate as CKRecordValue
        tripRecord["endDate"] = endDate as CKRecordValue
        tripRecord["category"] = category as CKRecordValue

        let itemRecords = itemList.map { item -> CKRecord in
            let itemRecord = item.toCKRecord()
            return itemRecord
        }
        let itemReferences = itemRecords.map { CKRecord.Reference(record: $0, action: .deleteSelf) }
        tripRecord["itemList"] = itemReferences as CKRecordValue

        return tripRecord
    }
}

//@Model
//class Bag {
//    var id: String = UUID().uuidString
//    var itemList = [Item]()
//    
////    @Relationship(inverse: \Trip.bag)
//    var trip: Trip?
////    enum CodingKeys: String, CodingKey {
////        case id, itemList
////    }
//
//    var isDecided: Bool = false
//
//    init(id: String = UUID().uuidString, itemList: [Item] = [Item]()) {
//        self.id = id
//        self.itemList = itemList
//    }
//    
//    static let exampleBag = Bag(itemList: [
//        Item.socks,
//        Item.tops,
//        Item.shoes,
//        Item.charger,
//    ])
//    
//    func toCKRecord() -> CKRecord {
//        let bagRecord = CKRecord(recordType: "Bag")
//        bagRecord["id"] = id as CKRecordValue
//        bagRecord["isDecided"] = isDecided as CKRecordValue
//        return bagRecord
//    }
//}

struct Item: Identifiable, Codable {
    var id = UUID()
    let name: String
    let category: String
    var userQuantity: Int
    let AIQuantity: Int
    var imageName: String = "default"
    var isDecided: Bool = false
    var isWearing: Bool = false
    var isPacked: Bool = false
    var isPair = false
    
    enum CodingKeys: String, CodingKey {
        case name, category, userQuantity, AIQuantity, imageName, isPair
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
    
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }

    static func jsonTemplate() -> String {
        return Item(name: "Item", category: "Category", userQuantity: 0, AIQuantity: 0).toJSONString() ?? ""
    }
    
    var image: UIImage {
        let myImage = UIImage(named: imageName) ?? UIImage(systemName: imageName) ?? UIImage(named: "default")!
        return myImage
    }
    
    func toCKRecord() -> CKRecord {
        let itemRecord = CKRecord(recordType: "Item")
        itemRecord["id"] = id.uuidString as CKRecordValue
        itemRecord["name"] = name as CKRecordValue
        itemRecord["category"] = category as CKRecordValue
        itemRecord["userQuantity"] = userQuantity as CKRecordValue
        itemRecord["AIQuantity"] = AIQuantity as CKRecordValue
        itemRecord["isDecided"] = isDecided as CKRecordValue
        itemRecord["isWearing"] = isWearing as CKRecordValue
        itemRecord["isPacked"] = isPacked as CKRecordValue
        itemRecord["imageName"] = imageName as CKRecordValue
        itemRecord["isPair"] = isPair as CKRecordValue
        return itemRecord
    }
}
