//
//  HypeController.swift
//  Hype
//
//  Created by Austin Goetz on 10/12/20.
//

import UIKit
import CloudKit

class HypeController {
    // MARK: - Class Properties
    /// Singleton/Shared Instance
    static let shared = HypeController()
    /// Local Source of Truth
    var hypes: [Hype] = []
    /// Public Database Reference
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD
    // Create/Save
    func saveHypeWith(text: String, completion: @escaping (Result<Hype, HypeError>) -> Void) {
        // Create new Hype object
        let newHype = Hype(body: text)
        // Initialize a CKRecord from a Hype object
        let hypeRecord = CKRecord(hype: newHype)
        publicDB.save(hypeRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.saveError))
            }
            
            guard let record = record,
                  let savedHype = Hype(ckRecord: record) else { return completion(.failure(.saveError)) }
            print("Saved Hype successfully")
            completion(.success(savedHype))
        }
    }
    
    // Read/Fetch
    func fetchAllHypes(completion: @escaping (Result<[Hype], HypeError>) -> Void) {
        let fetchAllPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: fetchAllPredicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.fetchError))
            }
            
            guard let records = records else { return completion(.failure(.fetchError)) }
            print("Fetched Hypes successfully")
            
            let fetchedHypes = records.compactMap({ Hype(ckRecord: $0) })
            completion(.success(fetchedHypes))
        }
    }
    
    // Update
    func update(_ hype: Hype, completion: @escaping (Result<Hype, HypeError>) -> Void) {
        let recordToUpdate = CKRecord(hype: hype)
        let updateOperation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate], recordIDsToDelete: nil)
        
        updateOperation.savePolicy = .changedKeys
        updateOperation.qualityOfService = .userInteractive
        updateOperation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.updateError))
            }
            
            guard let updatedRecord = records?.first,
                  let updatedHype = Hype(ckRecord: updatedRecord) else { return completion(.failure(.updateError)) }
            print("Updated Hype successfully")
            completion(.success(updatedHype))
        }
        publicDB.add(updateOperation)
    }
    
    // Delete
    func delete(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) -> Void) {
        
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        deleteOperation.savePolicy = .changedKeys
        deleteOperation.qualityOfService = .userInteractive
        deleteOperation.modifyRecordsCompletionBlock = { (_, recordIDs, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.deleteError))
            }
            
            guard let deletedRecordID = recordIDs else { return completion(.failure(.deleteError)) }
            print("Hype: \(deletedRecordID) was deleted successfully")
            completion(.success(true))
        }
        publicDB.add(deleteOperation)
    }
}
