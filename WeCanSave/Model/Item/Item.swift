//
//  Item.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 13/03/25.
//

import Foundation
import CloudKit
import UIKit

struct Item: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    let category: ItemCategory
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
    
    static let socks = Item(name: "Socks", category: .clothing, userQuantity: 4, AIQuantity: 4, isPair: true)
    static let tops = Item(name: "Tops", category: .clothing, userQuantity: 6, AIQuantity: 6)
    static let shoes = Item(name: "Shoes", category: .shoes, userQuantity: 2, AIQuantity: 2, isPair: true)
    static let charger = Item(name: "Charger", category: .tech, userQuantity: 1, AIQuantity: 1)
    
    static let socksDecided = Item(name: "Socks", category: .clothing, userQuantity: 4, AIQuantity: 4, isDecided: true, isPair: true)
    static let topsDecided = Item(name: "Tops", category: .clothing, userQuantity: 6, AIQuantity: 6, isDecided: true)
    static let shoesDecided = Item(name: "Shoes", category: .shoes, userQuantity: 2, AIQuantity: 2, isDecided: true, isPair: true)
    static let chargerDecided = Item(name: "Charger", category: .tech, userQuantity: 1, AIQuantity: 1, isDecided: true)
    
    mutating func incrementUserQuantity() {
        self.userQuantity += 1
        print(userQuantity)
    }
    
    mutating func decrementUserQuantity() {
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
    
    static func jsonTemplate() -> String {
        return Item(name: "Item", category: .clothing, userQuantity: 0, AIQuantity: 0).toJSONString() ?? ""
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
        return itemRecord
    }
}
