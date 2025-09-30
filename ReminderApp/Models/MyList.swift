//
//  MyList.swift
//  ReminderApp
//
//  Created by Raiyan Sharif on 30/9/25.
//

import Foundation
import SwiftData


@Model
class MyLists {
    var name: String
    var colorCode: String
    
    init(name: String, colorCode: String) {
        self.name = name
        self.colorCode = colorCode
    }
}
