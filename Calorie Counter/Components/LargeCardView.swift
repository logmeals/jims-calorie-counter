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
    @Binding var goal: Int? // Make goal optional

    @State private var showingAlert = false
    @State private var newGoal = ""

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
                    if let goal = goal {
                        Text("\(goal - (value ?? 0)) \(unit) remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .frame(maxWidth: 120, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 5)
                        CircularProgressView(percentage: Double((goal != 0) ? Double(value ?? 0) / Double(goal) * 100 : 0), color: color)
                            .frame(width: 40, height: 40)
                    } else {
                        Button(action: {
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
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
