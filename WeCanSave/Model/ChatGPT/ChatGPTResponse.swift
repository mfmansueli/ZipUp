//
//  ChatGPTResponse.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 04/03/25.
//

import Foundation

struct ChatGPTResponse: Codable {
    let choices: [ChatGPTChoice]
    
    var items: [Item] {
        choices.flatMap { $0.message.items }
    }
    
    enum CodingKeys: CodingKey {
        case choices
    }
}

struct ChatGPTChoice: Codable {
    let message: ChatGPTMessage
}

struct ChatGPTMessage: Codable {
    let content: String
    
    var items: [Item] {
        var jsonString = content
        // Remove everything before the first square bracket
        if let range = jsonString.range(of: "[") {
            jsonString = String(jsonString[range.lowerBound...])
        }
        // Add square brackets if they are not present
        if !jsonString.hasPrefix("[") {
            jsonString = "[\(jsonString)"
        }
        if !jsonString.hasSuffix("]") {
            jsonString = "\(jsonString)]"
        }
        guard let data = jsonString.data(using: .utf8) else { return [] }
        do {
            return try JSONDecoder().decode([Item].self, from: data)
        } catch {
            print("Error decoding items: \(error)")
            return []
        }
    }
    
    enum CodingKeys: CodingKey {
        case content
    }
}
