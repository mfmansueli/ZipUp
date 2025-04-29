//
//  DraftItem.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 27/04/25.
//

import UIKit

struct DraftItem {
    
    var id: UUID = UUID()
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

    init(from item: Item) {
        self.id = item.id
        self.name = item.name
        self.category = item.category
        self.userQuantity = item.userQuantity
        self.AIQuantity = item.AIQuantity
        self.imageName = item.imageName
        self.isDecided = item.isDecided
        self.isWearing = item.isWearing
        self.isPacked = item.isPacked
        self.isPair = item.isPair
        self.tipReason = item.tipReason
    }
    
    init(category: ItemCategory) {
        self.category = category
        self.userQuantity = 1
    }
    
    func updateItem(_ item: Item?) {
        item?.id = id
        item?.name = name
        item?.category = category
        item?.userQuantity = userQuantity
        item?.AIQuantity = AIQuantity
        item?.imageName = imageName
        item?.isDecided = isDecided
        item?.isWearing = isWearing
        item?.isPacked = isPacked
        item?.isPair = isPair
        item?.tipReason = tipReason
    }
    
    func toItem() -> Item {
        let item = Item()
        item.id = id
        item.name = name
        item.category = category
        item.userQuantity = userQuantity
        item.AIQuantity = AIQuantity
        item.imageName = imageName
        item.isDecided = isDecided
        item.isWearing = isWearing
        item.isPacked = isPacked
        item.isPair = isPair
        item.tipReason = tipReason
        return item
    }
    
    var image: UIImage {
        let myImage = UIImage(named: imageName) ?? UIImage(systemName: imageName) ?? UIImage(named: "default")!
        return myImage
    }
}
