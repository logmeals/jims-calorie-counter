//
//  Calorie_CounterApp.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/14/24.
//

import SwiftUI
import SwiftData

@main
struct Calorie_CounterApp: App {

    var body: some Scene {
        WindowGroup {
            MainTabView(selection: nil)
        }
        .modelContainer(for: [Weight.self, Meal.self])
    }
}
