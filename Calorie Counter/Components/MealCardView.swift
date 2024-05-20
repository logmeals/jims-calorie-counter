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
    var createdAt: Date
    var emoji: String
    var imageData: Data?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if imageData == nil {
                ZStack {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 40, height: 40)
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(Color.green.opacity(0.5), lineWidth: 1)
                        .frame(width: 40, height: 40)
                    Text(emoji)
                        .font(.system(size: 16))
                }
                .padding(.top, 8)
            } else if let uiImage = UIImage(data: imageData ?? Data()) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Adjust content mode as needed
                    .frame(width: 40, height: 40) // Set desired width and height
                    .clipped() // Ensure the image fits within the specified frame
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.top, 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.headline)
                        .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.black)
                    Spacer()
                    Text(formatTimestamp(date: createdAt))
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
            createdAt: Date(),
            emoji: "🍟"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
