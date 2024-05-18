//
//  AddView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI

struct AddView: View {
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
                    settingsSection(header: "Weight") {
                        settingsRow(title: "Enter your weight manually", imageName: "Received", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Pair smart-scale", imageName: "Scale", lastRow: true, gray: nil, danger: nil)
                    }
                    
                    settingsSection(header: "Meal") {
                        settingsRow(title: "Take a photo of your meal", imageName: "Camera", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Select meal photo from camera roll", imageName: "Photo", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Describe your meal", imageName: "Chat", lastRow: nil, gray: nil, danger: nil)
                        settingsRow(title: "Scan barcode", imageName: "Barcode", lastRow: true, gray: nil, danger: nil)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Add new")
        }
    }
}

#Preview {
    return MainTabView(selection: "Add")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
