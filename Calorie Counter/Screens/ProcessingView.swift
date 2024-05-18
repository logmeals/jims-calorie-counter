//
//  ProcessingView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProcessingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var step = 1;
    @State private var timeToProcess: String?
    @State private var newMeal: Meal?
    var mealDescription: String
    var startTime: Date = Date()
    
    init(mealDescription: String) {
        self.mealDescription = mealDescription
    }
    
    func startProcessingMeal() {
        callOpenAIAPIForMealDescription(mealDescription: mealDescription) { result in
            switch result {
                case .success(let response):
                    print("OpenAI Success")
                    print(response)
                    let meal = Meal(
                        emoji: response["emoji"] as? String,
                        createdAt: Date(),
                        label: response["label"] as? String,
                        details: mealDescription,
                        reviewedAt: Date(),
                        calories: response["calories"] as? Int,
                        protein: response["protein"] as? Int,
                        carbohydrates: response["carbohydrates"] as? Int,
                        fats: response["fats"] as? Int
                    )
                    modelContext.insert(meal)
                    do {
                        // Save new meal
                        try modelContext.save()
                        // Calculate time to process
                        timeToProcess = String(format: "%.1f", Date().timeIntervalSince(startTime))
                        // Move to next step
                        newMeal = meal
                        step = 3
                    } catch {
                        print(error)
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
            }
        }
    }

    var body: some View {
        NavigationView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing:10) {
                        Text(step > 2 ? "Meal added" : "Processing")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(step < 3 ? "Do not exit - If you do, your meal will be discarded." : "Your meal has finished, you can now exit safely.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    VStack(spacing:10) {
                        HStack {
                            Text("Progress:")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        VStack(spacing: 0) {
                            HStack(spacing: 15) {
                                if step == 1 {
                                    ProgressView()
                                }
                                if step > 1 {
                                    Text("✅")
                                }
                                Text("1. Uploading prompt data")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                            .padding()
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(UIColor.systemGray3)),
                                alignment: .bottom
                            )
                            
                            HStack(spacing: 15) {
                                if step == 1 {
                                    Text("✅").opacity(0)
                                }
                                if step == 2 {
                                    ProgressView()
                                }
                                if step > 2 {
                                    Text("✅")
                                }
                                Text("2. Estimating nutritional content")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                            .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                        )
                        .cornerRadius(10)
                        .shadow(color: Color(UIColor.systemGray3), radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
                    Spacer()
                    // Meal preview
                    // TODO: Add meal preview after OpenAI call finished
                    if newMeal != nil && step > 2 {
                        VStack(spacing: 15) {
                            Text("Your meal finished processing in \((timeToProcess ?? "")) seconds")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                            MealCardView(
                                label: newMeal?.label ?? "",
                                calories: newMeal?.calories ?? 0,
                                protein: newMeal?.protein ?? 0,
                                carbohydrates: newMeal?.carbohydrates ?? 0,
                                fats: newMeal?.fats ?? 0,
                                createdAt: newMeal?.createdAt ?? Date(),
                                emoji: newMeal?.emoji ?? "🍔"
                            )
                        }
                    }
                    Spacer()
                    // Footer
                    VStack(spacing:15) {
                        if timeToProcess == nil {
                            Text("Your meal is processing, please hold.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        Button(action: {
                            // TODO: Return to Summary screen
                        }) {
                            
                            Text("Return home")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(step < 3 ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
        }
        .background(Color(UIColor.systemGray6))
        .onAppear {
            step = 2
            startProcessingMeal()
        }
    }
}

#Preview {
    return ProcessingView(mealDescription: "A granola bar")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
