//
//  Item.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/14/24.
//

import Foundation
import SwiftData

@Model
final class Meal {
    var createdAt: Date
    var consumedAt: Date
    var label: String
    
    init(timestamp: Date) {
        self.createdAt = timestamp
        self.consumedAt = timestamp
        self.label = ""
    }
}
