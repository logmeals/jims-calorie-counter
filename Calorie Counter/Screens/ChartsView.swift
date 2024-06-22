//
//  ChartsView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 6/20/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Charts
import SwiftData

struct ChartData {
    let date: String
    let calories: Int
    let protein: Int
    let carbohydrates: Int
    let fats: Int
    let meals: Int
}

struct ChartView: View {
    let title: String
    let data: [(String, Int)]
    let color: Color
    let average: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("AVERAGE")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(average)
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }
            .padding([.leading, .trailing, .top])
            
            if data.isEmpty {
                Text("There's no data here yet.")
                    .foregroundColor(.gray)
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing, .bottom])
            } else {
                Chart(data, id: \.0) { element in
                    BarMark(
                        x: .value("Date", element.0),
                        y: .value("Value", element.1)
                    )
                    .foregroundStyle(color)
                }
                .padding([.leading, .trailing, .bottom])
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding([.leading, .trailing])
    }
}

struct ChartsView: View {
    @State private var selectedTab: String = "W"
    @Binding var navigateToSettings: Bool
    
    @Environment(\.modelContext) private var context: ModelContext
    @Query(sort: \Meal.createdAt, order: .reverse) var meals: [Meal]
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(formatDateRange(for: selectedTab))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Charts")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Button(action: {
                        navigateToSettings = true
                    }) {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 22, height: 22, alignment: .bottomTrailing)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                    }
                }.padding()

                VStack(spacing: 20) {
                    Picker("Select Period", selection: $selectedTab) {
                        // Text("D").tag("D")
                        Text("W").tag("W")
                        Text("M").tag("M")
                        Text("6M").tag("6M")
                        // Text("Y").tag("Y")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.leading, .trailing])
                    
                    let filteredData = fetchData(for: selectedTab)
                    
                    let caloriesData = filteredData.map { ($0.date, $0.calories) }
                    let proteinData = filteredData.map { ($0.date, $0.protein) }
                    let carbohydratesData = filteredData.map { ($0.date, $0.carbohydrates) }
                    let fatsData = filteredData.map { ($0.date, $0.fats) }
                    let mealsData = filteredData.map { ($0.date, $0.meals) }
                    
                    let averageCalories = caloriesData.map { $0.1 }.reduce(0, +) / (caloriesData.count == 0 ? 1 : caloriesData.count)
                    let averageProtein = proteinData.map { $0.1 }.reduce(0, +) / (proteinData.count == 0 ? 1 : proteinData.count)
                    let averageCarbohydrates = carbohydratesData.map { $0.1 }.reduce(0, +) / (carbohydratesData.count == 0 ? 1 : carbohydratesData.count)
                    let averageFats = fatsData.map { $0.1 }.reduce(0, +) / (fatsData.count == 0 ? 1 : fatsData.count)
                    let averageMeals = mealsData.map { $0.1 }.reduce(0, +) / (mealsData.count == 0 ? 1 : mealsData.count)
                    
                    ChartView(title: "Calories", data: caloriesData, color: .red, average: formatNumber(averageCalories) + " cal")
                    
                    ChartView(title: "Protein", data: proteinData, color: .green, average: formatNumber(averageProtein) + " g")
                    
                    ChartView(title: "Carbohydrates", data: carbohydratesData, color: .blue, average: formatNumber(averageCarbohydrates) + " g")
                    
                    ChartView(title: "Fats", data: fatsData, color: .orange, average: formatNumber(averageFats) + " g")
                    
                    ChartView(title: "Meals", data: mealsData, color: .purple, average: formatNumber(averageMeals))
                    
                    Spacer()
                }
            }
            .background(Color(UIColor.systemGray6))
        }
    }
    
    private func formatDateRange(for period: String) -> String {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        switch period {
        case "W":
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case "M":
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case "6M":
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case "Y":
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        default:
            startDate = calendar.startOfDay(for: now)
        }
        
        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: now))"
    }
    
    private func formatNumber(_ number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    private func fetchData(for period: String) -> [ChartData] {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date
        var dateFormatter: DateFormatter
        
        switch period {
        case "W":
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yy"
        case "M":
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yy"
        case "6M":
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yy"
        case "Y":
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yy"
        default:
            startDate = calendar.startOfDay(for: now)
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yy"
        }
        
        let filteredMeals = meals.filter { $0.createdAt >= startDate }
        var chartData: [ChartData] = []
        
        var groupedMeals: [String: (calories: Int, protein: Int, carbohydrates: Int, fats: Int, meals: Int)] = [:]
        
        for meal in filteredMeals {
            let dateKey = dateFormatter.string(from: meal.createdAt)
            
            if groupedMeals[dateKey] == nil {
                groupedMeals[dateKey] = (calories: 0, protein: 0, carbohydrates: 0, fats: 0, meals: 0)
            }
            
            groupedMeals[dateKey]?.calories += meal.calories ?? 0
            groupedMeals[dateKey]?.protein += meal.protein ?? 0
            groupedMeals[dateKey]?.carbohydrates += meal.carbohydrates ?? 0
            groupedMeals[dateKey]?.fats += meal.fats ?? 0
            groupedMeals[dateKey]?.meals += 1
        }
        
        for (date, values) in groupedMeals {
            chartData.append(ChartData(date: date, calories: values.calories, protein: values.protein, carbohydrates: values.carbohydrates, fats: values.fats, meals: values.meals))
        }
        chartData.sort { $0.date < $1.date }
        
        return chartData
    }
}

#Preview {
    return MainTabView(selection: "Charts")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
