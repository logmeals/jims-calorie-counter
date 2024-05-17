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
    @Attribute(.unique) var id: UUID
    var emoji: String
    var createdAt: Date
    var calories: Int?
    var protein: Int?
    var carbohydrates: Int?
    var fats: Int?
    var reviewedAt: Date?
    var label: String?
    var details: String?
    
    init(emoji: String?, createdAt: Date?, label: String?, details: String?, reviewedAt: Date?, calories: Int?, protein: Int?, carbohydrates: Int?, fats: Int?) {
        self.id = UUID()
        self.emoji = "⏳"
        self.createdAt = createdAt ?? Date()
        self.label = label
        self.details = details
        self.reviewedAt = reviewedAt
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fats = fats
    }
}

