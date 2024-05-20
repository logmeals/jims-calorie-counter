//
//  MealView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/19/24.
//

import Foundation
import SwiftUI
import SwiftData

// TODO: Add error view and state variable from processing page
// TODO: Add loading view for meal = nil

struct MealView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss // Environment variable to dismiss the view
    @State private var meal: Meal? = nil
    
    // Meal details update prompt
    @State private var editingValue: String = ""
    @State private var editingMeal: Bool = false
    @State private var newValue: String = ""
    @State private var editingDate: Bool = false
    @State private var newDate: Date = Date()
    
    var mealId: UUID
    var onDismiss: () -> Void
    
    init(mealId: UUID, onDismiss: @escaping () -> Void) {
        self.mealId = mealId
        self.onDismiss = onDismiss
    }
    
    private var predicate: Predicate<Meal> {
        return #Predicate { meal in
            meal.id == mealId
        }
    }

    func loadMeal() {
        do {
            let fetchDescriptor = FetchDescriptor<Meal>(predicate: predicate)
            let meals = try context.fetch(fetchDescriptor)
            if(meals.count < 1) {
                // Throw error
            } else {
                meal = meals[0]
                newDate = meal?.createdAt ?? Date()
            }
        } catch {
            print("Failed to fetch meals: \(error)")
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing:20) {
                // Title
                VStack(spacing:10) {
                    Text("Edit meal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("View and edit your meal details.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // Image
                if meal != nil {
                    if meal!.photo == nil {
                        Text(meal?.emoji ?? "🍎")
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        Image(uiImage: UIImage(data: meal!.photo ?? Data()) ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill) // Adjust content mode as needed
                            .frame(width: 60, height: 60) // Set desired width and height
                            .clipped() // Ensure the image fits within the specified frame
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            
            // Meal details
            settingsSection(header: "Details", content: {
                settingsRow(
                    title: "Calories",
                    value: "\(formatNumberWithCommas(meal?.calories ?? 0)) calories",
                    lastRow: nil,
                    gray: nil,
                    danger: nil,
                    onTap: {_ in 
                        editingValue = "calories"
                        editingMeal.toggle()
                    },
                    grayValue: false
                )
                settingsRow(
                    title: "Protein",
                    value: "\(formatNumberWithCommas(meal?.protein ?? 0))g",
                    lastRow: nil,
                    gray: nil,
                    danger: nil,
                    onTap: {_ in
                        editingValue = "protein"
                        editingMeal.toggle()
                    },
                    grayValue: false
                )
                settingsRow(
                    title: "Carbohydrates",
                    value: "\(formatNumberWithCommas(meal?.carbohydrates ?? 0))g",
                    lastRow: nil,
                    gray: nil,
                    danger: nil,
                    onTap: {_ in
                        editingValue = "carbohydrates"
                        editingMeal.toggle()
                    },
                    grayValue: false
                )
                settingsRow(
                    title: "Fats",
                    value: "\(formatNumberWithCommas(meal?.fats ?? 0))g",
                    lastRow: nil,
                    gray: nil,
                    danger: nil,
                    onTap: {_ in
                        editingValue = "fats"
                        editingMeal.toggle()
                    },
                    grayValue: false
                )
                settingsRow(
                    title: "Consumed",
                    value: "\(formatDate(meal?.createdAt ?? Date())) @ \(formatTimestamp(date: meal?.createdAt ?? Date()))",
                    lastRow: nil,
                    gray: nil,
                    danger: nil,
                    onTap: {_ in
                        editingDate.toggle()
                    },
                    grayValue: false
                )
                settingsRow(
                    title: "Label",
                    value: meal?.label,
                    lastRow: nil,
                    gray: nil,
                    danger: nil,
                    onTap: {_ in
                        editingValue = "label"
                        editingMeal.toggle()
                    },
                    grayValue: false
                )
                settingsRow(
                    title: "Details",
                    value: meal?.details,
                    lastRow: nil,
                    gray: nil,
                    danger: nil,
                    onTap: {_ in
                        editingValue = "details"
                        editingMeal.toggle()
                    },
                    grayValue: false
                )
            })
            
            Spacer()
            
            // Footer
            Button(action: {
                // Save changes
                do {
                    try context.save()
                    dismiss()
                    onDismiss()
                } catch {
                    print(error)
                }
            }) {
                Text("Save changes")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(context.hasChanges ? .blue : .gray)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadMeal()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if meal != nil {
                        context.delete(meal!)
                        dismiss()
                        onDismiss()
                    }
                }) {
                    Image("Garbage")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }
        }
        .alert("Edit \(editingValue)", isPresented: $editingMeal) {
            TextField("", text: $newValue)
                .keyboardType(
                    (editingValue != "label" && editingValue != "details") ? .numberPad : .default
                )
            Button("Cancel", action: {
                editingMeal = false
                editingValue = ""
                newValue = ""
                newDate = Date()

            })
            Button("Save", action: {
                switch(editingValue) {
                    case "calories":
                        meal?.calories = Int(newValue)
                    case "protein":
                        meal?.protein = Int(newValue)
                    case "carbohydrates":
                        meal?.carbohydrates = Int(newValue)
                    case "fats":
                        meal?.fats = Int(newValue)
                    case "label":
                        meal?.label = newValue
                    case "details":
                        meal?.details = newValue
                    case "consumed":
                        meal?.createdAt  = newDate
                    default:
                        print("Error: Hit default statement in switch")
                }
                // Exit alert
                editingMeal = false
                editingValue = ""
                newValue = ""
                newDate = Date()
            })
        }
        .sheet(isPresented: $editingDate, content: {
            VStack(spacing:10) {
                Text("When did you eat this meal?")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                DatePicker("Select date and time you ate this meal", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .labelsHidden()

                Spacer()
                
                Button(action: {
                    meal?.createdAt = newDate
                    // Exit sheet
                    editingDate = false
                    editingValue = ""
                    newValue = ""
                    newDate = Date()
                }) {
                    Text("Update and return")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                
                Button(action: {
                    editingDate = false
                    editingValue = ""
                    newValue = ""
                    newDate = Date()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray)
                .cornerRadius(10)
            }
            .padding()
        })
    }
}
