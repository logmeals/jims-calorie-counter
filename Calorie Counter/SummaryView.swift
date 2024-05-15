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
}

struct SummaryView_Preview: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
