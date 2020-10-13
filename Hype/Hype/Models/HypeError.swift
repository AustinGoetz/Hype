//
//  HypeError.swift
//  Hype
//
//  Created by Austin Goetz on 10/12/20.
//

import Foundation

enum HypeError: LocalizedError {
    case saveError
    case fetchError
    case updateError
    case deleteError
    
    var errorDescription: String? {
        switch self {
        case .saveError:
            return "There was an error saving your Hype to the cloud - please try again later"
        case .fetchError:
            return "There was an error loading your Hypes - please try again later"
        case .updateError:
            return "There was an error updating your Hype - please try again later"
        case .deleteError:
            return "There was an error deleting your Hype - please try again later"
        }
    }
}
