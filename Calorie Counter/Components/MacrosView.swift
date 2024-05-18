//
//  MacrosView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct MacroItemView: View {
    var title: String
    var unit: String
    var consumed: Int
    var color: Color
    var goal: Int?
    @State private var showingAlert = false
    @State private var newGoal = ""
    @State private var goalState: Int?
    
    init(title: String, unit: String, consumed: Int, color: Color, goal: Int?) {
        self.title = title
        self.unit = unit
        self.consumed = consumed
        self.color = color
        self.goal = goal
        _goalState = State(initialValue: goal)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(color)
                HStack(alignment: .bottom, spacing: 2) {
                    Text(consumed.description)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if let goalState = goalState {
                let remaining = goalState - consumed
                let percentage = (goalState != 0) ? Double(consumed) / Double(goalState) * 100 : 0
                HStack {
                    Text("\(remaining)g remaining")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                    CircularProgressView(percentage: percentage, color: color)
                        .frame(width: 40, height: 40)
                }
            } else {
                Button(action: {
                    showingAlert.toggle()
                }) {
                    Text("Set goal")
                        .font(.caption)
                        .foregroundColor(color)
                        .padding(.top, 39)
                }
                .alert("Edit \(title) goal", isPresented: $showingAlert) {
                    TextField("ex: 92g", text: $newGoal)
                    Button("OK", action: {
                        let desiredGoal = Int($newGoal.wrappedValue)
                        if desiredGoal != 0 {
                            // Save new goal
                            UserDefaults.standard.set(desiredGoal, forKey: "\(title.lowercased())Goal")
                            // Update goal in macro item view immediately without refreshing view
                            goalState = desiredGoal
                        }
                    })
                } message: {
                    Text("Enter your new goal:")
                }
            }
        }
    }
}


struct MacrosView: View {
    var createdAt: Date?
    var proteinConsumed: Int?
    var proteinGoal: Int?
    var carbohydratesConsumed: Int?
    var carbohydratesGoal: Int?
    var fatsConsumed: Int?
    var fatsGoal: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Macros")
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
                if createdAt != nil {
                    Text(formatTimestamp(date: createdAt ?? Date()))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            

            MacroItemView(
                title: "Protein",
                unit: "g",
                consumed: proteinConsumed ?? 0,
                color: .green, goal: proteinGoal
            )
            
            Divider()
            
            MacroItemView(
                title: "Carbohydrates",
                unit: "g",
                consumed: carbohydratesConsumed ?? 0,
                color: .blue, goal: carbohydratesGoal
            )
            
            Divider()
        
            MacroItemView(
                title: "Fats",
                unit: "g",
                consumed: fatsConsumed ?? 0,
                color: .orange, goal: fatsGoal
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview("Mixed") {
        MacrosView(createdAt: Date(),
                   proteinConsumed: 113, proteinGoal: 150,
                   carbohydratesConsumed: 92, carbohydratesGoal: 123,
                   fatsConsumed: 43)
            .padding()
}

#Preview("With goals") {
        MacrosView(createdAt: Date(),
                   proteinConsumed: 113, proteinGoal: 150,
                   carbohydratesConsumed: 92, carbohydratesGoal: 123,
                   fatsConsumed: 43, fatsGoal: 100)
            .padding()
}

#Preview("Without goals") {
        MacrosView(createdAt: Date(),
                   proteinConsumed: 113,
                   carbohydratesConsumed: 92,
                   fatsConsumed: 43)
            .padding()
}
