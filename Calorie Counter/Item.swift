//
//  Item.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/14/24.
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
