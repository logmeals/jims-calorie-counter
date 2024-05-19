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
    @Binding var goal: Int? // Make goal optional

    @State private var showingAlert = false
    @State private var newGoal = ""

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
                    Button("Cancel", action: {
                        showingAlert.toggle()
                    })
                    Button("Save", action: {
                        if let desiredGoal = Int(newGoal) {
                            goal = desiredGoal
                        } else {
                            goal = nil
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
    var carbohydratesConsumed: Int?
    var fatsConsumed: Int?

    @Binding var proteinGoal: Int? // Make goal optional
    @Binding var carbohydratesGoal: Int? // Make goal optional
    @Binding var fatsGoal: Int? // Make goal optional

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Macros")
                    .font(.headline)
                    .foregroundColor(.purple)
                Spacer()
                if let createdAt = createdAt {
                    Text(formatTimestamp(date: createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            MacroItemView(
                title: "Protein",
                unit: "g",
                consumed: proteinConsumed ?? 0,
                color: .green,
                goal: $proteinGoal
            )
            Divider()
            MacroItemView(
                title: "Carbohydrates",
                unit: "g",
                consumed: carbohydratesConsumed ?? 0,
                color: .blue,
                goal: $carbohydratesGoal
            )
            Divider()
            MacroItemView(
                title: "Fats",
                unit: "g",
                consumed: fatsConsumed ?? 0,
                color: .orange,
                goal: $fatsGoal
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
