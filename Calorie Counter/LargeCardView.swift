//
//  LargeCardView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct LargeCardView: View {
    var title: String
    var value: String
    var unit: String
    var remaining: String?
    var percentage: Int
    var color: Color
    var time: String?
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(color)
                    Spacer()
                    if let time = time {
                        Text(time)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: 150, alignment: .trailing)
                    }
                }
                
            }
            HStack {
                HStack(alignment: .bottom, spacing: 10) {
                    Text(value)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack {
                    if let remaining = remaining {
                        Text(remaining)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .frame(maxWidth: 120, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 5)
                        // Adjust max width to prevent overflow
                    }
                    CircularProgressView(percentage: 40.0, color: color)
                        .frame(width: 40, height: 40) // Adjust the size of the circular progress
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct CaloriesCardView_Previews: PreviewProvider {
    static var previews: some View {
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
        .padding()
    }
}
