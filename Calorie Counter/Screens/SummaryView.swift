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
    @State private var displayDate: Date = Date()
    @State private var isDatePickerPresented: Bool = false
    @Environment(\.modelContext) private var context: ModelContext

    @State private var meals: [Meal] = []
    
    @AppStorage("caloriesGoal") private var caloriesGoalStored: Int = -1
    @AppStorage("proteinGoal") private var proteinGoalStored: Int = -1
    @AppStorage("carbohydratesGoal") private var carbohydratesGoalStored: Int = -1
    @AppStorage("fatsGoal") private var fatsGoalStored: Int = -1
    
    @State private var caloriesGoal: Int?
    @State private var proteinGoal: Int?
    @State private var carbohydratesGoal: Int?
    @State private var fatsGoal: Int?
    @Binding var navigateToMeal: Bool
    @Binding var mealId: UUID


    private var predicate: Predicate<Meal> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: displayDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return #Predicate { meal in
            meal.createdAt >= startOfDay && meal.createdAt < endOfDay
        }
    }

    func fetchMeals() {
        do {
            let fetchDescriptor = FetchDescriptor<Meal>(predicate: predicate)
            meals = try context.fetch(fetchDescriptor)
        } catch {
            print("Failed to fetch meals: \(error)")
        }
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
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(formatDate(displayDate))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Summary")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .onAppear {
                                    // Initialize local state with stored values
                                    caloriesGoal = caloriesGoalStored >= 0 ? caloriesGoalStored : nil
                                    proteinGoal = proteinGoalStored >= 0 ? proteinGoalStored : nil
                                    carbohydratesGoal = carbohydratesGoalStored >= 0 ? carbohydratesGoalStored : nil
                                    fatsGoal = fatsGoalStored >= 0 ? fatsGoalStored : nil
                                    fetchMeals()
                                }
                        }
                        Button(action: {
                            isDatePickerPresented.toggle()
                        }) {
                            Image("Calendar")
                                .resizable()
                                .frame(width: 22, height: 22, alignment: .bottomTrailing)
                                .padding(.top, 20)
                        }
                    }
                    
                    // Datepicker
                    if isDatePickerPresented {
                        VStack(spacing: 0) {
                            DatePicker("Select a Date", selection: $displayDate, displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                                .onChange(of: displayDate) { newValue in
                                    fetchMeals()
                                }
                            HStack(spacing: 5) {
                                Button(action: {
                                    isDatePickerPresented.toggle()
                                }) {
                                    Text("Close Date Picker")
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue.opacity(0.65), lineWidth: 1)
                                )
                                Button(action: {
                                    displayDate = Date()
                                    fetchMeals()
                                }) {
                                    Image("Undo")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .padding(10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.45), lineWidth: 1)
                                )
                            }
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
                        ForEach(meals.filter { $0.reviewedAt != nil }) { meal in
                            Button(action: {
                                // Open Meal Detail on Tap
                                mealId = meal.id ?? UUID()
                                navigateToMeal = true
                                
                            }) {
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
    }
}

#Preview {
    return MainTabView(selection: "Summary")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}

