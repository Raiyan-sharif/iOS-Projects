//
//  Item.swift
//  ReminderApp
//
//  Created by Raiyan Sharif on 25/9/25.
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
