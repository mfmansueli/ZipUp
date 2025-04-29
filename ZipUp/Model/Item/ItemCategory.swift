//
//  ItemCategory.swift
//  ZipUp
//
//  Created by Mateus Mansuelli on 17/03/25.
//

enum ItemCategory: String, Codable, CaseIterable {
    case clothing = "Clothing"
    case shoes = "Shoes"
    case accessories = "Accessories"
    case toiletries = "Toiletries"
    case tech = "Tech"
    case documents = "Documents"
    case other = "Other"
}
