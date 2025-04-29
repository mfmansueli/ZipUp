//
//  Item.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 13/03/25.
//

import Foundation
import CloudKit
import UIKit
import SwiftData

@Model
class Item: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String = ""
    var category: ItemCategory = ItemCategory.clothing
    var userQuantity: Int = 0
    var AIQuantity: Int = 0
    var imageName: String = "default"
    var isDecided: Bool = false
    var isWearing: Bool = false
    var isPacked: Bool = false
    var isPair = false
    var tipReason: String = ""
    @Relationship(inverse: \Trip.itemList) var trip: Trip?

    enum CodingKeys: String, CodingKey {
        case name, category, userQuantity, AIQuantity, imageName, isPair, tipReason
    }

    init(id: UUID = UUID(), name: String, category: ItemCategory, userQuantity: Int, AIQuantity: Int, imageName: String = "", isDecided: Bool = false, isWearing: Bool = false, isPacked: Bool = false, isPair: Bool = false, tipReason: String = "") {
        self.id = id
        self.name = name
        self.category = category
        self.userQuantity = userQuantity
        self.AIQuantity = AIQuantity
        self.imageName = imageName
        self.isDecided = isDecided
        self.isWearing = isWearing
        self.isPacked = isPacked
        self.isPair = isPair
        self.tipReason = tipReason
    }
    
    init(category: ItemCategory, trip: Trip) {
        self.category = category
        self.trip = trip
    }
    
    init() {
        
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(ItemCategory.self, forKey: .category)
        userQuantity = try container.decode(Int.self, forKey: .userQuantity)
        AIQuantity = try container.decode(Int.self, forKey: .AIQuantity)
        imageName = try container.decode(String.self, forKey: .imageName)
        isPair = try container.decode(Bool.self, forKey: .isPair)
        tipReason = try container.decode(String.self, forKey: .tipReason)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(userQuantity, forKey: .userQuantity)
        try container.encode(AIQuantity, forKey: .AIQuantity)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(isPair, forKey: .isPair)
        try container.encode(tipReason, forKey: .tipReason)
    }

    func incrementUserQuantity() {
        self.userQuantity += 1
        print(userQuantity)
    }

    func decrementUserQuantity() {
        if self.userQuantity > 1 {
            self.userQuantity -= 1
        }
        print(userQuantity)
    }

    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }

    var image: UIImage {
        let myImage = UIImage(named: imageName) ?? UIImage(systemName: imageName) ?? UIImage(named: "default")!
        return myImage
    }

    func toCKRecord() -> CKRecord {
        let itemRecord = CKRecord(recordType: "Item")
        itemRecord["id"] = id.uuidString as CKRecordValue
        itemRecord["name"] = name as CKRecordValue
        itemRecord["category"] = category.rawValue as CKRecordValue
        itemRecord["userQuantity"] = userQuantity as CKRecordValue
        itemRecord["AIQuantity"] = AIQuantity as CKRecordValue
        itemRecord["isDecided"] = isDecided as CKRecordValue
        itemRecord["isWearing"] = isWearing as CKRecordValue
        itemRecord["isPacked"] = isPacked as CKRecordValue
        itemRecord["imageName"] = imageName as CKRecordValue
        itemRecord["isPair"] = isPair as CKRecordValue
        itemRecord["tipReason"] = tipReason as CKRecordValue
        return itemRecord
    }
    
    static let socks = Item(name: "Socks", category: .clothing, userQuantity: 4, AIQuantity: 4, imageName: "default", isDecided: false, isWearing: false, isPacked: false, isPair: true, tipReason: "")
    static let tops = Item(name: "Tops", category: .clothing, userQuantity: 6, AIQuantity: 6, imageName: "default", isDecided: false, isWearing: false, isPacked: false, isPair: false, tipReason: "")
    static let shoes = Item(name: "Shoes", category: .shoes, userQuantity: 2, AIQuantity: 2, imageName: "default", isDecided: false, isWearing: false, isPacked: false, isPair: true, tipReason: "")
    static let charger = Item(name: "Charger", category: .tech, userQuantity: 1, AIQuantity: 1, imageName: "default", isDecided: false, isWearing: false, isPacked: false, isPair: false, tipReason: "")
    static let socksDecided = Item(name: "Socks", category: .clothing, userQuantity: 4, AIQuantity: 4, imageName: "default", isDecided: true, isWearing: false, isPacked: false, isPair: true, tipReason: "")
    static let topsDecided = Item(name: "Tops", category: .clothing, userQuantity: 6, AIQuantity: 6, imageName: "default", isDecided: true, isWearing: false, isPacked: false, isPair: false, tipReason: "")
    static let shoesDecided = Item(name: "Shoes", category: .shoes, userQuantity: 2, AIQuantity: 2, imageName: "default", isDecided: true, isWearing: false, isPacked: false, isPair: true, tipReason: "")
    static let chargerDecided = Item(name: "Charger", category: .tech, userQuantity: 1, AIQuantity: 1, imageName: "default", isDecided: true, isWearing: false, isPacked: false, isPair: false, tipReason: "")
}
