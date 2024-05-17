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
    var goal: Int?
    var color: Color
    
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
            if let goal = goal {
                let remaining = goal - consumed
                let percentage = (goal != 0) ? Double(consumed) / Double(goal) * 100 : 0
                HStack {
                    Text("\(remaining)g remaining")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing, 5)
                    CircularProgressView(percentage: percentage, color: color)
                        .frame(width: 40, height: 40)
                }
            } else {
                Text("Set goal")
                    .font(.caption)
                    .foregroundColor(color)
            }
        }
    }
}


struct MacrosView: View {
    var time: String
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
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            

            MacroItemView(
                title: "Protein",
                unit: "g",
                consumed: proteinConsumed ?? 0,
                goal: proteinGoal,
                color: .green
            )
            
            Divider()
            
            MacroItemView(
                title: "Carbohydrates",
                unit: "g",
                consumed: carbohydratesConsumed ?? 0,
                goal: carbohydratesGoal,
                color: .blue
            )
            
            Divider()
        
            MacroItemView(
                title: "Fats",
                unit: "g",
                consumed: fatsConsumed ?? 0,
                goal: fatsGoal,
                color: .orange
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview("Mixed") {
        MacrosView(time: "9:15 AM",
                   proteinConsumed: 113, proteinGoal: 150,
                   carbohydratesConsumed: 92, carbohydratesGoal: 123,
                   fatsConsumed: 43)
            .padding()
}

#Preview("With goals") {
        MacrosView(time: "9:15 AM",
                   proteinConsumed: 113, proteinGoal: 150,
                   carbohydratesConsumed: 92, carbohydratesGoal: 123,
                   fatsConsumed: 43, fatsGoal: 100)
            .padding()
}

#Preview("Without goals") {
        MacrosView(time: "9:15 AM",
                   proteinConsumed: 113,
                   carbohydratesConsumed: 92,
                   fatsConsumed: 43)
            .padding()
}
