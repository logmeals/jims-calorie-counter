//
//  SummaryView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct SummaryView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date and Summary Title
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Monday, June 12")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Summary")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)

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
                        .padding(.horizontal)
                        
                        // Calories Card
                        SummaryCardView(
                            title: "Calories",
                            value: "1,394",
                            unit: "cal",
                            remaining: "300 calories remaining",
                            percentage: 80,
                            color: .red,
                            time: "9:10 AM"
                        )
                        
                        // Weight Card
                        SummaryCardView(
                            title: "Weight",
                            value: "213",
                            unit: "lbs",
                            remaining: nil,
                            percentage: 62,
                            color: .blue,
                            time: "7:15 AM"
                        )
                        
                        // Macros Card
                        VStack(spacing: 15) {
                            Text("Macros")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            SummaryCardView(
                                title: "Protein",
                                value: "113",
                                unit: "g",
                                remaining: "80g remaining",
                                percentage: 80,
                                color: .green,
                                time: "9:10 AM"
                            )
                            SummaryCardView(
                                title: "Carbohydrates",
                                value: "92",
                                unit: "g",
                                remaining: "31g remaining",
                                percentage: 75,
                                color: .blue,
                                time: nil
                            )
                            SummaryCardView(
                                title: "Fats",
                                value: "43",
                                unit: "g",
                                remaining: "22g remaining",
                                percentage: 51,
                                color: .orange,
                                time: nil
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
}

struct SummaryCardView: View {
    var title: String
    var value: String
    var unit: String
    var remaining: String?
    var percentage: Int
    var color: Color
    var time: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
                if let time = time {
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            HStack(alignment: .bottom) {
                Text(value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            if let remaining = remaining {
                Text(remaining)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            ProgressBar(percentage: percentage, color: color)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ProgressBar: View {
    var percentage: Int
    var color: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(height: 10)
                .opacity(0.3)
                .foregroundColor(color)
            Rectangle()
                .frame(width: CGFloat(percentage) * 2, height: 10)
                .foregroundColor(color)
        }
        .cornerRadius(5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}
