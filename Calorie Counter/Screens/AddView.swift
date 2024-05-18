//
//  AddView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI

struct AddView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var caloriesGoal: String = "2,000 calories / day"
    @State private var proteinGoal: String = "23g / day"
    @State private var weightGoal: String = "192 lbs"
    @State private var askForDescription: Bool = true
    @State private var mealsToShow: String = "3"
    @State private var mealReminders: Bool = false
    @State private var sendAnonymousData: Bool = true
    @State private var showingDescribeMealAlert: Bool = false
    @State private var mealDescription: String = ""
    @Binding var selection: String

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    settingsSection(header: "Weight") {
                        settingsRow(title: "Enter your weight manually", imageName: "Received", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Pair smart-scale", imageName: "Scale", lastRow: true, gray: nil, danger: nil, onTap: nil)
                    }
                    
                    settingsSection(header: "Meal") {
                        settingsRow(title: "Take a photo of your meal", imageName: "Camera", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Select meal photo from camera roll", imageName: "Photo", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Describe your meal", imageName: "Chat", lastRow: nil, gray: nil, danger: nil, onTap: {_ in
                            showingDescribeMealAlert.toggle()
                            }
                        )
                                .alert("Describe your meal", isPresented: $showingDescribeMealAlert) {
                                    TextField("ex: A 12ct chicken nugget meal from Chickfila", text: $mealDescription)
                                    Button("Save meal", action: {
                                        let desiredMealDescription = $mealDescription.wrappedValue
                                        if desiredMealDescription != "" {
                                            // TODO: Move to Processing page?
                                            print("Prompt sent to OpenAI")
                                            callOpenAIAPIForMealDescription(mealDescription: desiredMealDescription) { result in
                                                switch result {
                                                case .success(let response):
                                                    print("OpenAI Success")
                                                    print(response)
                                                    let meal = Meal(
                                                        emoji: response["emoji"] as? String,
                                                        createdAt: Date(),
                                                        label: response["label"] as? String,
                                                        details: desiredMealDescription,
                                                        reviewedAt: Date(),
                                                        calories: response["calories"] as? Int,
                                                        protein: response["protein"] as? Int,
                                                        carbohydrates: response["carbohydrates"] as? Int,
                                                        fats: response["fats"] as? Int
                                                    )
                                                    modelContext.insert(meal)
                                                    mealDescription = ""
                                                    do {
                                                        try modelContext.save()
                                                        // TODO: Redirect to Meal detail page rather than Summary
                                                        selection = "Summary"
                                                    } catch {
                                                        print(error)
                                                    }
                                                case .failure(let error):
                                                    print("Error: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                    })
                                    Button("Cancel", action: {
                                        showingDescribeMealAlert.toggle()
                                    })
                                } message: {
                                    Text("Enter as much information as you can. ex: What and how much you ate, from where, modifications, etc")
                                }
                        settingsRow(title: "Scan barcode", imageName: "Barcode", lastRow: true, gray: nil, danger: nil, onTap: nil)
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
