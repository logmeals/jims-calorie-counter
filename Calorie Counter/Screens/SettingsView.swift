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
    @State private var askForDescription: Bool = true
    @State private var mealsToShow: String = "3"
    @State private var mealReminders: Bool = false
    @State private var sendAnonymousData: Bool = true
    
    @State private var newGoal: String = ""
    @State private var calorieGoal: Int = 0
    // @State private var weightGoal: Int = 0
    @State private var proteinGoal: Int = 0
    @State private var carbohydratesGoal: Int = 0
    @State private var fatsGoal: Int = 0
    
    @State private var editingGoal: String = ""
    // Computed property to check if editingGoal is not empty
    private var isEditing: Bool {
        return !editingGoal.isEmpty
    }
    
    @State private var editingOpenAIKey: Bool = false
    @State private var newOpenAIKey: String = ""
    @State private var openAIKey: String = ""
    
    func editGoal(goal: String) {
        editingGoal = goal
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    settingsSection(header: "Preferences") {
                        
                        settingsRow(title: "OpenAI API Key", value: openAIKey != "" ? "******" : "N/A", lastRow: true, gray: nil, danger: nil, onTap: {_ in
                            editingOpenAIKey = true
                        }, grayValue: openAIKey == "")
                        .onAppear {
                            openAIKey = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
                        }
                        
                        //settingsRow(title: "Ask for description on meal photos?", value: askForDescription ? "Yes" : "No", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        //settingsRow(title: "Meals to show by default?", value: mealsToShow, lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        //settingsRow(title: "Meal reminders?", value: mealReminders ? "Enabled" : "Disabled", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        //settingsRow(title: "Send anonymous usage data?", value: sendAnonymousData ? "Enabled" : "Disabled", lastRow: true, gray: nil, danger: nil, onTap: nil)
                        
                    }
                    
                    /*
                    settingsSection(header: "Favorites") {
                        settingsRow(title: "Calories", value: nil, imageName: "Bars", lastRow: nil, gray: true, danger: nil, onTap: nil)
                            /*.onDrag {
                                return NSItemProvider()
                            }*/
                        settingsRow(title: "Weight", value: nil, imageName: "Bars", lastRow: nil, gray: true, danger: nil, onTap: nil)
                            /*.onDrag {
                                return NSItemProvider()
                            }*/
                        settingsRow(title: "Macros", value: nil, imageName: "Bars", lastRow: true, gray: true, danger: nil, onTap: nil)
                    }
                    */
                     
                    settingsSection(header: "Goals") {
                        settingsRow(title: "Calories", value: calorieGoal > 0 ? "\(formatNumberWithCommas(calorieGoal)) calories" : "N/A", lastRow: nil, gray: nil, danger: nil, onTap: editGoal, grayValue: calorieGoal == 0)
                            .onAppear {
                                calorieGoal = UserDefaults.standard.integer(forKey: "caloriesGoal")
                            }
                        settingsRow(title: "Protein", value: proteinGoal > 0 ? "\(proteinGoal)g" : "N/A", lastRow: nil, gray: nil, danger: nil, onTap: editGoal, grayValue: proteinGoal == 0)
                            .onAppear {
                                proteinGoal = UserDefaults.standard.integer(forKey: "proteinGoal")
                            }
                        settingsRow(title: "Carbohydrates", value: carbohydratesGoal > 0 ? "\(carbohydratesGoal)g" : "N/A", lastRow: nil, gray: nil, danger: nil, onTap: editGoal, grayValue: carbohydratesGoal == 0)
                            .onAppear {
                                carbohydratesGoal = UserDefaults.standard.integer(forKey: "carbohydratesGoal")
                            }
                        settingsRow(title: "Fats", value: fatsGoal > 0 ? "\(fatsGoal)g" : "N/A", lastRow: nil, gray: nil, danger: nil, onTap: editGoal, grayValue: fatsGoal == 0)
                            .onAppear {
                                fatsGoal = UserDefaults.standard.integer(forKey: "fatsGoal")
                            }
                        //settingsRow(title: "Weight", value: "\(weightGoal)g/day", lastRow: true, gray: nil, danger: nil, onTap: nil)
                    }
                    
                    settingsSection(header: "Community") {
                        settingsRow(title: "Join our Discord Community", imageName: "Discord", lastRow: true, gray: nil, danger: nil, onTap: {_ in
                                // TODO: Redirect to join Discord Link
                            UIApplication.shared.open(URL(string: "https://discord.gg/TT8W6DfXHe")!)
                        }, grayValue: false)
                        // settingsRow(title: "Refer a friend, get $5!", imageName: "Gift", lastRow: true, gray: nil, danger: nil, onTap: nil)
                    }
                    
                    
                    /*
                    settingsSection(header: "Support") {
                        settingsRow(title: "Restore purchases", imageName: "Bag", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Upgrade and unlock full access", imageName: "Lightning", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Export data", imageName: "Export", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Report bug", imageName: "Bug", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Contact support", imageName: "Raft", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "View Privacy Policy / EULA", imageName: "Building", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Delete all data", imageName: "Garbage", lastRow: true, gray: nil, danger: true, onTap: nil)
                    }
                     */
                }
                .padding()
            }
            .alert("Edit \(editingGoal) goal", isPresented: Binding<Bool>(
                get: { self.isEditing },
                set: { newValue in
                    if !newValue {
                        self.editingGoal = ""
                    }
                })) {
                TextField("ex: 92g", text: $newGoal)
                Button("Save goal", action: {
                    let desiredGoal = Int($newGoal.wrappedValue)
                    if desiredGoal != 0 {
                        // Save new goal
                        UserDefaults.standard.set(desiredGoal, forKey: "\(editingGoal.lowercased())Goal")
                        // Update goal in macro item view immediately without refreshing view
                        if(editingGoal.lowercased() == "calories") { calorieGoal = desiredGoal ?? 0 }
                        if(editingGoal.lowercased() == "protein") { proteinGoal = desiredGoal ?? 0 }
                        if(editingGoal.lowercased() == "carbohydrates") { carbohydratesGoal = desiredGoal ?? 0 }
                        if(editingGoal.lowercased() == "fats") {fatsGoal = desiredGoal ?? 0 }
                    }
                    editingGoal = ""
                    newGoal = ""
                })
                    Button("Delete goal", action: {
                        // Update User Defaults
                        UserDefaults.standard.set(nil, forKey: "\(editingGoal.lowercased())Goal")
                        // Update goal in macro item view immediately without refreshing view
                        if(editingGoal.lowercased() == "calories") { calorieGoal = 0 }
                        if(editingGoal.lowercased() == "protein") { proteinGoal = 0 }
                        if(editingGoal.lowercased() == "carbohydrates") { carbohydratesGoal = 0 }
                        if(editingGoal.lowercased() == "fats") {fatsGoal = 0 }
                        editingGoal = ""
                        newGoal = ""
                    })
                    Button("Cancel", action: {
                        editingGoal = ""
                        newGoal = ""
                    })
            } message: {
                Text("Enter your new goal:")
            }
            .alert("Edit OpenAI API Key", isPresented: $editingOpenAIKey) {
                TextField("ex: sk....", text: $newOpenAIKey)
                Button("Save", action: {
                    let desiredAPIKey = $newOpenAIKey.wrappedValue
                    if desiredAPIKey != "" {
                        // Save new API Key
                        UserDefaults.standard.set(desiredAPIKey, forKey: "openAIAPIKey")
                        openAIKey = desiredAPIKey
                        newOpenAIKey = ""
                    }
                })
                Button("Delete", action: {
                    // Update User Defaults
                    UserDefaults.standard.set(nil, forKey: "openAIAPIKey")
                    openAIKey = ""
                    newOpenAIKey = ""
                })
                Button("Cancel", action: {
                    editingOpenAIKey = false
                    newOpenAIKey = ""
                })
            } message: {
                Text("Keys are stored securely on your device, and are never sent to anyone besides OpenAI.")
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
