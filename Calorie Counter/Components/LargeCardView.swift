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
    var remaining: Int?
    var percentage: Int?
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
                    Text(value != nil ? formatNumberWithCommas(value ?? 0).description : "N/A")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(unit.prefix(3))
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack {
                    if let remaining = remaining {
                        Text("\(remaining.description) \(unit) remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .frame(maxWidth: 120, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 5)
                        // Adjust max width to prevent overflow
                    }
                    if let percentage = percentage {
                        CircularProgressView(percentage: Double(percentage), color: color)
                            .frame(width: 40, height: 40) // Adjust the size of the circular progress
                    } else {
                        Button(action: {
                                            // Button action
                        }) {
                            Text("Add goal")
                                .font(.caption)
                                .foregroundColor(color)
                        }.padding(.top, 30)
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
            remaining: 300,
            percentage: 80,
            color: .red,
            time: "9:10 AM"
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
            time: "9:10 AM"
        )
        .previewLayout(.sizeThatFits)
        .padding()
}
