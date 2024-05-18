//
//  LargeCardView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct LargeCardView: View {
    var title: String
    var value: Int?
    var unit: String
    var color: Color
    var createdAt: Date?
    var goal: Int?
    @State private var showingAlert = false
    @State private var newGoal = ""
    @State private var goalState: Int?
    
    init(title: String, value: Int?, unit: String, color: Color, createdAt: Date?, goal: Int?) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
        self.createdAt = createdAt
        self.goal = goal
        _goalState = State.init(initialValue: goal)
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(color)
                    Spacer()
                    if let createdAt = createdAt {
                        Text(formatTimestamp(date: createdAt))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: 150, alignment: .trailing)
                    }
                }
                
            }
            HStack {
                HStack(alignment: .bottom, spacing: 10) {
                    Text(value != nil ? formatNumberWithCommas(value ?? 0).description : "N/A")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(unit.prefix(3))
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack {
                    if let goalState = goalState {
                        Text("\(goalState - (value ?? 0)) \(unit) remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .frame(maxWidth: 120, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 5)
                        // Adjust max width to prevent overflow
                    }
                    if let goalState = goalState {
                        CircularProgressView(percentage: Double((goalState != 0) ? Double(value ?? 0) / Double(goalState) * 100 : 0), color: color)
                            .frame(width: 40, height: 40) // Adjust the size of the circular progress
                    } else {
                        Button(action: {
                            // Button action
                            showingAlert.toggle()
                        }) {
                            Text("Add goal")
                                .font(.caption)
                                .foregroundColor(color)
                        }
                            .padding(.top, 30)
                            .alert("Edit \(title) goal", isPresented: $showingAlert) {
                                TextField("ex: 92g", text: $newGoal)
                                Button("OK", action: {
                                    let desiredGoal = Int($newGoal.wrappedValue)
                                    if desiredGoal != 0 {
                                        // Save new goal
                                        UserDefaults.standard.set(desiredGoal, forKey: "\(title.lowercased())Goal")
                                        print("Setting UserDefaults \(title.lowercased())Goal")
                                        print((desiredGoal ?? 0).description)
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
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview("With goal") {
        LargeCardView(
            title: "Calories",
            value: 1394,
            unit: "calories",
            color: .red,
            createdAt: Date(),
            goal: 2000
        )
        .previewLayout(.sizeThatFits)
        .padding()
}

#Preview("Without goal") {
        LargeCardView(
            title: "Calories",
            value: 1394,
            unit: "calories",
            color: .red,
            createdAt: Date(),
            goal: nil
        )
        .previewLayout(.sizeThatFits)
        .padding()
}
