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
        guard let data = content.data(using: .utf8) else { return [] }
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
