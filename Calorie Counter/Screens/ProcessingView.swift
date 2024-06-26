//
//  ProcessingView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProcessingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss // Environment variable to dismiss the view
    @State private var step = 1
    @State private var timeToProcess: String?
    @State private var newMeal: Meal?
    @State private var errorHasOccured: Bool = false
    @Binding var barcode: String
    @Binding var mealDescription: String
    @Binding var imageData: Data?
    @State private var startTime: Date = Date()
    var onDismiss: () -> Void
    
    func startProcessingMeal() {
        startTime = Date()
        if(barcode != nil && barcode != "") {
            // Call Barcode API
            fetchProductInfo(upc: barcode) { label, description, calories, protein, carbohydrates, fat in
                step = 2
                if let label = label {
                    // TODO: Send results to GPT-3 to improve label + description, and generate emoji
                    newMeal = Meal(
                        emoji: "🌀",
                        createdAt: Date(),
                        label: label,
                        details: description,
                        reviewedAt: Date(),
                        calories: Int(calories ?? 0.0),
                        protein: Int(protein ?? 0.0),
                        carbohydrates: Int(carbohydrates ?? 0.0),
                        fats: Int(fat ?? 0.0),
                        photo: nil
                    )
                    do {
                        step = 3
                        modelContext.insert(newMeal!)
                        try modelContext.save()
                        barcode = ""
                        mealDescription = ""
                        imageData = nil
                        // Calculate time to process
                        timeToProcess = String(format: "%.1f", Date().timeIntervalSince(startTime))
                    } catch {
                        print("Error: Failed to save meal info from barcode.")
                        errorHasOccured = true
                    }
                } else {
                    print("Error: Failed to fetch product info from barcode.")
                    errorHasOccured = true
                }
            }

        } else {
            callAIAPI(mealDescription: mealDescription, imageData: imageData) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        let meal = Meal(
                            emoji: response["emoji"] as? String,
                            createdAt: Date(),
                            label: response["label"] as? String,
                            details: mealDescription,
                            reviewedAt: Date(),
                            calories: response["calories"] as? Int ?? 0,
                            protein: response["protein"] as? Int ?? 0,
                            carbohydrates: response["carbohydrates"] as? Int ?? 0,
                            fats: response["fats"] as? Int ?? 0,
                            photo: imageData
                        )
                        modelContext.insert(meal)
                        do {
                            // Save new meal
                            try modelContext.save()
                            // Calculate time to process
                            timeToProcess = String(format: "%.1f", Date().timeIntervalSince(startTime))
                            // Move to next step
                            newMeal = meal
                            step = 3
                        } catch {
                            print(error)
                            errorHasOccured = true
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("Error: \(error.localizedDescription)")
                        errorHasOccured = true
                    }
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing:10) {
                Text(step > 2 ? "Meal added" : "Processing")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(step < 3 ? "Do not exit - Your meal will be discarded." : "Your meal has finished, you can exit safely.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack(spacing:10) {
                HStack {
                    Text("Progress:")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                VStack(spacing: 0) {
                    HStack(spacing: 15) {
                        if step == 1 {
                            if(errorHasOccured) {
                                Text("❌")
                            } else {
                                ProgressView()
                            }
                        }
                        if step > 1 {
                            Text("✅")
                        }
                        Text("1. Uploading prompt data")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                    .padding()
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(UIColor.systemGray3)),
                        alignment: .bottom
                    )
                        
                    HStack(spacing: 15) {
                        if step == 1 {
                            Text("✅").opacity(0)
                        }
                        if step == 2 {
                            if(errorHasOccured) {
                                Text("❌")
                            } else {
                                ProgressView()
                            }
                        }
                        if step > 2 {
                            Text("✅")
                        }
                        Text("2. Estimating nutritional content")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
                    .padding()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                )
                .cornerRadius(10)
                .shadow(color: Color(UIColor.systemGray3), radius: 10)
            }
            Spacer()
            
            // Meal preview
            if !errorHasOccured && newMeal != nil && step > 2 {
                VStack(spacing: 15) {
                    Text("Your meal finished processing in \((timeToProcess ?? "")) seconds")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    MealCardView(
                        label: newMeal?.label ?? "",
                        calories: newMeal?.calories ?? 0,
                        protein: newMeal?.protein ?? 0,
                        carbohydrates: newMeal?.carbohydrates ?? 0,
                        fats: newMeal?.fats ?? 0,
                        createdAt: newMeal?.createdAt ?? Date(),
                        emoji: newMeal?.emoji ?? "🍔"
                    )
                }
            }
            
            // Error notification
            if errorHasOccured {
                VStack(spacing: 15) {
                    Text("We were unable to add your meal. Check your meal description and OpenAI API Key, then try again.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
                    
            Spacer()
            // Footer
            VStack(spacing:15) {
                if timeToProcess == nil && !errorHasOccured {
                    Text("Your meal is processing, please hold.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Button(action: {
                    DispatchQueue.main.async {
                        // Clear variables
                        imageData = nil
                        mealDescription = ""
                        barcode = ""
                        // Exit screen
                        dismiss() // Pop the view off the navigation stack
                        onDismiss() // Set the tab selection to "Summary"
                    }
                }) {
                    Text("Return home")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(step < 3 || errorHasOccured ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .onAppear {
            DispatchQueue.main.async {
                step = 2
                startProcessingMeal()
            }
        }
    }
}
