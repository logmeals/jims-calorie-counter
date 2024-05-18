//
//  SettingsView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var caloriesGoal: String = "2,000 calories / day"
    @State private var proteinGoal: String = "23g / day"
    @State private var weightGoal: String = "192 lbs"
    @State private var askForDescription: Bool = true
    @State private var mealsToShow: String = "3"
    @State private var mealReminders: Bool = false
    @State private var sendAnonymousData: Bool = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    settingsSection(header: "Favorites") {
                        settingsRow(title: "Calories", value: nil, imageName: "Bars", lastRow: nil, gray: true, danger: nil)
                            /*.onDrag {
                                print("Dragging item: Calories")
                                return NSItemProvider()
                            }*/
                        settingsRow(title: "Weight", value: nil, imageName: "Bars", lastRow: nil, gray: true, danger: nil)
                            /*.onDrag {
                                print("Dragging item: Weight")
                                return NSItemProvider()
                            }*/
                        settingsRow(title: "Macros", value: nil, imageName: "Bars", lastRow: nil, gray: true, danger: nil)
                        settingsRow(title: "Meals", value: nil, imageName: "Bars", lastRow: true, gray: true, danger: nil)
                    }
                    
                    settingsSection(header: "Goals") {
                        settingsRow(title: "Calories", value: caloriesGoal, lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Protein", value: proteinGoal, lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Weight", value: weightGoal, lastRow: true, gray: nil, danger: nil)
                    }
                    
                    settingsSection(header: "Preferences") {
                        settingsRow(title: "Ask for description on meal photos?", value: askForDescription ? "Yes" : "No", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Meals to show by default?", value: mealsToShow, lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Meal reminders?", value: mealReminders ? "Enabled" : "Disabled", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Send anonymous usage data?", value: sendAnonymousData ? "Enabled" : "Disabled", lastRow: true, gray: nil, danger: nil)
                    }
                    
                    settingsSection(header: "Community") {
                        settingsRow(title: "Join our Discord Community", imageName: "Discord", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Refer a friend, get $5!", imageName: "Gift", lastRow: true, gray: nil, danger: nil)
                    }
                    
                    settingsSection(header: "Support") {
                        settingsRow(title: "Restore purchases", imageName: "Bag", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Upgrade and unlock full access", imageName: "Lightning", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Export data", imageName: "Export", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Report bug", imageName: "Bug", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Contact support", imageName: "Raft", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "View Privacy Policy / EULA", imageName: "Building", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Delete all data", imageName: "Garbage", lastRow: true, gray: nil, danger: true)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    return MainTabView(selection: "Settings")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
