//
//  Trip.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 13/03/25.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit
import CloudKit

@Model
class Trip: ObservableObject {
    var id = UUID()
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
    
    @Relationship(deleteRule: .cascade)
    var itemList: [Item]? = []
    var category: String = ""
    var isFinished = false
    
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
    
    static let exampleTripDecided = Trip(
        destinationName: "Dublin",
        //        destinationLatLong: CLLocationCoordinate2D(latitude: 53.34570, longitude: -6.268386),
        destinationLat: "53.34570",
        destinationLong: "-6.268386",
        startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!,
        endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 18))!,
        category: "Adventure",
        itemList: Trip.exampleBagDecided
    )
    
    func toCKRecord() -> CKRecord {
        let tripRecord = CKRecord(recordType: "Trip")
        tripRecord["destinationName"] = destinationName as CKRecordValue
        tripRecord["destinationLat"] = destinationLat as CKRecordValue
        tripRecord["destinationLong"] = destinationLong as CKRecordValue
        tripRecord["startDate"] = startDate as CKRecordValue
        tripRecord["endDate"] = endDate as CKRecordValue
        tripRecord["category"] = category as CKRecordValue

        let itemRecords = itemList?.compactMap { item -> CKRecord in
            let itemRecord = item.toCKRecord()
            return itemRecord
        }
        if let itemReferences = itemRecords?.compactMap({ CKRecord.Reference(record: $0, action: .deleteSelf) }) {
            tripRecord["itemList"] = itemReferences as CKRecordValue
        }
        return tripRecord
    }
    
    static let exampleBagDecided = [
        Item.socksDecided,
        Item.topsDecided,
        Item.shoesDecided,
        Item.chargerDecided,
    ]
    
    func getItemCount() -> Int {
        guard let itemList = itemList else { return 0 }
        var count: Int = 0

        for item in itemList {
            if item.isDecided {
                count += item.userQuantity
            }
        }
        
        print("getCount \(count)")
        return count
    }
    
    func isBagDecided() -> Bool {
        guard let itemList = itemList else { return false }
        for item in itemList {
            if !item.isDecided {
                return false
            }
        }
        return true
    }
    
    func undecideBag() {
        guard let itemList = itemList else { return }
        for item in itemList {
            item.isDecided = false
        }
    }
    
    func undecidedItems() -> [Item] {
        guard let itemList = itemList else { return [] }
        return itemList.filter { !$0.isDecided }
    }
    
    func addItem(_ item: Item) {
        if let index = itemList?.firstIndex(where: { $0.id == item.id }) {
            itemList?[index] = item // Replace the existing item
        } else {
            itemList?.append(item) // Add the new item
        }
    }
    
    func remove(item: Item) {
        itemList?.removeAll { currentItem in
            currentItem.id == item.id
        }
    }
    
    func totalDecidedAndUndecidedItems() -> (decided: Int, undecided: Int) {
        guard let itemList = itemList else { return (decided: 0, undecided: 0) }
        var decidedCount = 0
        var undecidedCount = 0
        for item in itemList {
            
            if item.isDecided {
                decidedCount += item.userQuantity
            } else {
                undecidedCount += item.userQuantity
            }
        }
        return (decided: decidedCount, undecided: undecidedCount)
    }
    
    var progress: Double {
        guard let itemList = itemList else { return 0 }
        var decidedCount = 0
        for item in itemList {
            
            if item.isDecided {
                decidedCount += 1
            }
        }
        
        print("bagProgress \(Double(decidedCount) / Double(itemList.count))")
        return Double(decidedCount) / Double(itemList.count)
    }
    
}

extension Trip: Equatable {
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.id == rhs.id
    }
}
extension Trip {
    func getItem(byId id: UUID) -> Item? {
        return itemList?.first { $0.id == id }
    }
    
    func getItems(byCategory category: ItemCategory) -> [Item] {
        return itemList?.filter { $0.category == category } ?? []
    }
}
