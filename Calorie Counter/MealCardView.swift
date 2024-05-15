//
//  MealCardView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct MealCardView: View {
    var label: String
    var calories: Int
    var protein: Int
    var carbohydrates: Int
    var fats: Int
    var time: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 40, height: 40)
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 40, height: 40)
                Text("🍔")
                    .font(.system(size: 16))
            }
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.headline)
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text("\(calories) calories")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(protein)g Protein, \(carbohydrates)g Carbohydrates, \(fats)g Fats")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct MealCardView_Preview: PreviewProvider {
    static var previews: some View {
        MealCardView(
            label: "Breakfast at McDonalds",
            calories: 830,
            protein: 17,
            carbohydrates: 24,
            fats: 13,
            time: "9:10 AM"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
