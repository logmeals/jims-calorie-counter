//
//  Item.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/14/24.
//

import Foundation
import SwiftData

@Model
final class Meal: Identifiable {
    var id: UUID
    var emoji: String
    var createdAt: Date
    var reviewedAt: Date?
    var label: String?
    var details: String?
    var calories: Int?
    var protein: Int?
    var carbohydrates: Int?
    var fats: Int?
    
    init(id: UUID = UUID(), createdAt: Date = Date()) {
        self.id = id
        self.emoji = "⏳"
        self.createdAt = createdAt
    }
}
