//
//  DateExtension.swift
//  Hype
//
//  Created by Austin Goetz on 10/12/20.
//

import Foundation

extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
