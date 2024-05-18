//
//  SettingsView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI

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
                        settingsRow(title: "Calories", imageName: "Bars", lastRow: nil, gray: true, danger: nil)
                        settingsRow(title: "Weight", imageName: "Bars", lastRow: nil, gray: true, danger: nil)
                        settingsRow(title: "Macros", imageName: "Bars", lastRow: nil, gray: true, danger: nil)
                        settingsRow(title: "Meals", imageName: "Bars", lastRow: true, gray: true, danger: nil)
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
    
    @ViewBuilder
    private func settingsSection<Content: View>(header: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(header)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 5)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color(UIColor.systemGray4), radius: 5)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(UIColor.systemGray3), lineWidth: 1)
            )
        }
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private func settingsRow(title: String, value: String? = nil, imageName: String? = nil, lastRow: Bool?, gray: Bool?, danger: Bool?) -> some View {
        Button(action: { handleTap(option: title) }) {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(danger == true ? Color.red : gray == true ? Color(UIColor.systemGray) : Color.black)
                Spacer()
                if let value = value {
                    Text(value)
                        .foregroundColor(.blue)
                }
                if let imageName = imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(danger == true ? Color.red.opacity(0.12) : Color.white)
            .contentShape(Rectangle())
        }
        .overlay(
            Rectangle()
                .frame(height: lastRow != true ? 1 : 0)
                .foregroundColor(Color(UIColor.systemGray3)),
            alignment: .bottom
        )
        .buttonStyle(PlainButtonStyle())
    }
    
    // Empty function to handle taps
    func handleTap(option: String) {
        print("Tapped on \(option)")
        // Add your functionality here
    }
}

#Preview {
    return MainTabView(selection: "Settings")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
