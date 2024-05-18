//
//  Weight.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftData

@Model
final class Weight: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var weight: Int
    
    init(id: UUID = UUID(), weight: Int, createdAt: Date?) {
        self.id = UUID()
        self.createdAt = createdAt ?? Date()
        self.weight = weight
    }
}

