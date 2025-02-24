//
//  Item.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 24/02/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
