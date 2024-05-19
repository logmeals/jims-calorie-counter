//
//  SummaryView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI
import SwiftData
import Foundation

struct SummaryView: View {
    @State private var displayDate: String = ""
    @Environment(\.modelContext) private var context
    @Query private var meals: [Meal]
    
    @AppStorage("caloriesGoal") private var caloriesGoalStored: Int = -1
    @AppStorage("proteinGoal") private var proteinGoalStored: Int = -1
    @AppStorage("carbohydratesGoal") private var carbohydratesGoalStored: Int = -1
    @AppStorage("fatsGoal") private var fatsGoalStored: Int = -1
    
    @State private var caloriesGoal: Int?
    @State private var proteinGoal: Int?
    @State private var carbohydratesGoal: Int?
    @State private var fatsGoal: Int?

    func macrosConsumed() -> (calories: Int, protein: Int, carbohydrates: Int, fats: Int) {
        let totalCalories = meals.reduce(0) { $0 + ($1.calories ?? 0) }
        let totalProtein = meals.reduce(0) { $0 + ($1.protein ?? 0) }
        let totalCarbohydrates = meals.reduce(0) { $0 + ($1.carbohydrates ?? 0) }
        let totalFats = meals.reduce(0) { $0 + ($1.fats ?? 0) }
        
        return (totalCalories, totalProtein, totalCarbohydrates, totalFats)
    }
    
    func latestTimestamp() -> (weight: Date?, meal: Date?) {
        let weightTimestamp: Date? = nil
        let mealTimestamp: Date? = meals.max(by: { $0.createdAt < $1.createdAt })?.createdAt
        
        return (weight: weightTimestamp, meal: mealTimestamp)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date and Summary Title
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .onAppear {
                                // Initialize local state with stored values
                                caloriesGoal = caloriesGoalStored >= 0 ? caloriesGoalStored : nil
                                proteinGoal = proteinGoalStored >= 0 ? proteinGoalStored : nil
                                carbohydratesGoal = carbohydratesGoalStored >= 0 ? carbohydratesGoalStored : nil
                                fatsGoal = fatsGoalStored >= 0 ? fatsGoalStored : nil
                            }
                    }

                    // Favorites Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Favorites")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        LargeCardView(
                            title: "Calories",
                            value: macrosConsumed().calories,
                            unit: "calories",
                            color: .red,
                            createdAt: latestTimestamp().meal,
                            goal: Binding(
                                get: { caloriesGoal },
                                set: { newValue in
                                    caloriesGoal = newValue
                                    caloriesGoalStored = newValue ?? -1
                                }
                            )
                        )
                        .previewLayout(.sizeThatFits)
                        
                        MacrosView(
                            createdAt: latestTimestamp().meal,
                            proteinConsumed: macrosConsumed().protein,
                            carbohydratesConsumed: macrosConsumed().carbohydrates,
                            fatsConsumed: macrosConsumed().fats,
                            proteinGoal: Binding(
                                get: { proteinGoal },
                                set: { newValue in
                                    proteinGoal = newValue
                                    proteinGoalStored = newValue ?? -1
                                }
                            ),
                            carbohydratesGoal: Binding(
                                get: { carbohydratesGoal },
                                set: { newValue in
                                    carbohydratesGoal = newValue
                                    carbohydratesGoalStored = newValue ?? -1
                                }
                            ),
                            fatsGoal: Binding(
                                get: { fatsGoal },
                                set: { newValue in
                                    fatsGoal = newValue
                                    fatsGoalStored = newValue ?? -1
                                }
                            )
                        )
                    }
                    
                    // Meals Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Meals")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            if meals.count > 3 {
                                Button(action: {
                                    // Edit action
                                }) {}
                            }
                        }
                        ForEach(meals.filter { $0.reviewedAt == nil }) { meal in
                            MealProcessingView(
                                createdAt: meal.createdAt
                            )
                        }
                        ForEach(meals.filter { $0.reviewedAt != nil }) { meal in
                            MealCardView(
                                label: meal.label ?? "N/A",
                                calories: meal.calories ?? 0,
                                protein: meal.protein ?? 0,
                                carbohydrates: meal.carbohydrates ?? 0,
                                fats: meal.fats ?? 0,
                                createdAt: meal.createdAt,
                                emoji: meal.emoji
                            )
                        }
                        if meals.isEmpty {
                            Text("You haven't added any meals yet.")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 10)
                                .padding(.bottom, 40)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 70)
                .padding(.bottom, 110)
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.all)
        }
        .modelContainer(for: Meal.self)
    }
}

#Preview {
    return MainTabView(selection: "Summary")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
