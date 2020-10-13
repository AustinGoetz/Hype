//
//  Hype.swift
//  Hype
//
//  Created by Austin Goetz on 10/12/20.
//

import Foundation
import CloudKit

struct HypeStrings {
    static let recordTypeKey = "Hype"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
}

class Hype {
    let body: String
    let timestamp: Date
    let recordID: CKRecord.ID
    
    init(body: String, timestamp: Date, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
    }
}

// MARK: - Extensions
/// Creates a Hype object from a CKRecord
extension Hype {
    convenience init?(ckRecord: CKRecord) {
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
              let timestamp = ckRecord[HypeStrings.timestampKey] as? Date else { return nil }
        
        self.init(body: body, timestamp: timestamp)
    }
}

/// Creates a CKRecord from a Hype object
extension CKRecord {
    convenience init(hype: Hype) {
        self.init(recordType: HypeStrings.recordTypeKey, recordID: hype.recordID)
        
        self.setValuesForKeys([
            HypeStrings.bodyKey: hype.body,
            HypeStrings.timestampKey : hype.timestamp
        ])
    }
}
