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
    @State private var calorieGoal: Int
    @State private var weightGoal: Int
    @State private var proteinGoal: Int
    @State private var carbohydratesGoal: Int
    @State private var fatsGoal: Int


    
    init() {
        // Fetch calorie goal
        let calorieGoal = UserDefaults.standard.integer(forKey: "caloriesGoal")
        _calorieGoal = State(initialValue: calorieGoal)
        // Fetch weight goal
        let weightGoal = UserDefaults.standard.integer(forKey: "weightGoal")
        _weightGoal = State(initialValue: weightGoal)
        // Fetch protein goal
        let proteinGoal = UserDefaults.standard.integer(forKey: "proteinGoal")
        _proteinGoal = State(initialValue: proteinGoal)
        // Fetch weight goal
        let carbohydratesGoal = UserDefaults.standard.integer(forKey: "carbohydratesGoal")
        _carbohydratesGoal = State(initialValue: carbohydratesGoal)
        // Fetch weight goal
        let fatsGoal = UserDefaults.standard.integer(forKey: "fatsGoal")
        _fatsGoal = State(initialValue: fatsGoal)
    }
    
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
                        Text(displayDate)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .onAppear {
                                let date = Date()
                                displayDate = formatDate(date)
                            }
                        Text("Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    // Favorites Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Favorites")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                // Edit action
                            }) {
                                Text("Edit")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        LargeCardView(
                            title: "Calories",
                            value: macrosConsumed().calories,
                            unit: "calories",
                            color: .red,
                            createdAt: latestTimestamp().meal,
                            goal: calorieGoal != 0 ? calorieGoal : nil
                        )
                        .previewLayout(.sizeThatFits)
                        
                        LargeCardView(
                            title: "Weight",
                            value: nil,
                            unit: "lbs",
                            color: .indigo,
                            createdAt: latestTimestamp().weight,
                            goal: weightGoal != 0 ? weightGoal : nil
                        )
                        
                        MacrosView(
                            createdAt: latestTimestamp().meal,
                            proteinConsumed: macrosConsumed().protein,
                            proteinGoal: proteinGoal != 0 ? proteinGoal : nil,
                            carbohydratesConsumed: macrosConsumed().carbohydrates,
                            carbohydratesGoal: carbohydratesGoal != 0 ? carbohydratesGoal : nil,
                            fatsConsumed: macrosConsumed().fats,
                            fatsGoal: fatsGoal != 0 ? fatsGoal : nil
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
                                }) {
                                    Text("Show more")
                                        .foregroundColor(.blue)
                                }
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
                            Text("You haven't added any meals yet today.")
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

        }.modelContainer(for: Meal.self)
    }
    
}

#Preview {
    return MainTabView(selection: "Summary")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
