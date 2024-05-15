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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Meal.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SummaryView()
        }
        .modelContainer(sharedModelContainer)
    }
}
