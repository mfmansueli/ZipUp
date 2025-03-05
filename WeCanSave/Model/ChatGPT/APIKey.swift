//
//  APIKey.swift
//  WeCanSave
//
//  Created by Mateus Mansuelli on 04/03/25.
//


import Foundation
import CloudKit

struct APIKey: Identifiable {
    let id: String
    let key: String
    
    static func ckRecord(from ckRecord: CKRecord) -> APIKey {
        let key = ckRecord["key"] as? String ?? ""
        let id = ckRecord.recordID.recordName
        return APIKey(id: id, key: key)
    }
}