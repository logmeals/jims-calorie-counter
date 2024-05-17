//
//  SummaryView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct SummaryView: View {
    @State private var displayDate: String = ""
    
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
                            value: "1,394",
                            unit: "cal",
                            remaining: "300 calories remaining",
                            percentage: 80,
                            color: .red,
                            time: "9:10 AM"
                        )
                        .previewLayout(.sizeThatFits)
                        
                        LargeCardView(
                            title: "Weight",
                            value: "213",
                            unit: "lbs",
                            percentage: 60,
                            color: .indigo,
                            time: "7:15 AM"
                        )
                        
                        MacrosView(
                            time: "9:15 AM",
                            proteinConsumed: 113,
                            proteinGoal: 150,
                            carbohydratesConsumed: 92,
                            carbohydratesGoal: 123,
                            fatsConsumed: 43
                        )
                    }
                    
                    // Meals Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Meals")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                // Edit action
                            }) {
                                Text("Show more")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        MealCardView(
                            label: "Breakfast at McDonalds",
                            calories: 830,
                            protein: 17,
                            carbohydrates: 24,
                            fats: 13,
                            time: "9:10 AM"
                        )
                        
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
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if let yesterday = yesterday, calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM d"
            
            var formattedDate = dateFormatter.string(from: date)
            let currentYear = calendar.component(.year, from: today)
            let dateYear = calendar.component(.year, from: date)
            
            if dateYear != currentYear {
                formattedDate += ", \(dateYear)"
            }
            
            return formattedDate
        }
    }
    
}

struct SummaryView_Preview: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
