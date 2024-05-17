//
//  MealProcessingView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//


import SwiftUI

struct MealProcessingView: View {
    var createdAt: Date
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                Circle()
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                    .frame(width: 40, height: 40)
                Text("⏳")
                    .font(.system(size: 16))
            }
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Loading...")
                        .font(.headline)
                    Spacer()
                    Text(formatTimestamp(date: createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Text("Please hold for results.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    MealProcessingView(
        createdAt: Date()
    )
    .previewLayout(.sizeThatFits)
    .padding()
}

