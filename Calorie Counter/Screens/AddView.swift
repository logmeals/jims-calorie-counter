//
//  AddView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI
import UIKit

struct AddView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var askForDescription: Bool = true
    @State private var showingDescribeMealAlert: Bool = false
    @State private var openAIAPIKey:String = ""
    
    @State private var showingImagePicker: Bool = false
    @State private var imagePreview: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @Binding var barcode: String
    
    @Binding var selection: String
    @Binding var navigateToProcessing: Bool
    @Binding var mealDescription: String
    @Binding var imageData: Data?
    
    @Binding var appIsOwned: Bool
    
    @State private var localTokensRemaining: Int?
    
    // Meal details update prompt
    @State private var editingValue: String = ""
    @State private var editingMeal: Bool = false
    @State private var newValue: String = ""
    @State private var editingDate: Bool = false
    @State private var newDate: Date = Date()
    @State private var meal: Meal? = nil
    
    @State var selectedTab = "Barcode"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Select Period", selection: $selectedTab) {
                        // Text("D").tag("D")
                        Text("Barcode").tag("Barcode")
                        Image("OpenAI Logo").frame(width: 41, height: 11).tag("AI")
                        Text("Macros").tag("Macros")
                        // Text("Y").tag("Y")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.leading, .trailing])
                    
                    VStack(spacing:25) {
                        
                        if(selectedTab == "Barcode") {
                            VStack(spacing: 5) {
                                Text("Center barcode below:")
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                Text("Page will immediately exit and begin adding meal once barcode is captured.")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                            }
                            BarcodeScannerView { code in
                                // Save barcode for processing
                                barcode = code
                                // Open processing page
                                navigateToProcessing = true
                            }
                            .frame(maxWidth: .infinity, idealHeight: 380)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 4)
                            )
                        } else if(selectedTab == "AI" && localTokensRemaining ?? 0 >= 4) {
                            VStack(spacing:20) {
                                VStack(alignment: .center, spacing: 10) {
                                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: 300)
                                            .cornerRadius(12)
                                    } else {
                                        VStack (spacing: 10) {
                                            Image(systemName: "camera.on.rectangle.fill")
                                                .opacity(0.45)
                                            Text("Tap for camera, hold for gallery")
                                                .fontWeight(.semibold)
                                                .opacity(0.45)
                                        }
                                        .padding(40)
                                        .padding(.top, 20)
                                        .padding(.bottom, 20)
                                    }
                                }
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                .background(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                )
                                .onTapGesture(perform: {
                                    // Open camera
                                    sourceType = .camera
                                    showingImagePicker.toggle()
                                })
                                .onLongPressGesture(perform: {
                                    // Open camera roll
                                    sourceType = .photoLibrary
                                    showingImagePicker.toggle()
                                })

                                VStack(spacing: 5) {
                                    Text("Meal details:")
                                        .font(.title)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .multilineTextAlignment(.center)
                                    Text("(Optional) What and how much you ate, from where, modifications, etc")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.gray)
                                }
                                TextField("ex: A 12ct chicken nugget meal from Chickfila", text: $mealDescription)
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 60, alignment: .top)
                                    .multilineTextAlignment(.center)
                                    .padding(12)
                                    .background(.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                    )
                                Spacer()
                                HStack {
                                    Text("Save meal")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                .padding(20)
                                .background((!mealDescription.isEmpty || imageData != nil) ? Color.blue : Color.gray)
                                .cornerRadius(12)
                                .onTapGesture(perform: {
                                    if(!mealDescription.isEmpty || imageData != nil) {
                                        navigateToProcessing = true
                                    }
                                })
                            }
                            .padding(20)
                        } else if(selectedTab == "Macros") {
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
                                if let newMeal = meal {
                                    // Save changes
                                    do {
                                        // Insert meal to context
                                        modelContext.insert(newMeal)
                                        // Save meal to context
                                        try modelContext.save()
                                        // Navigate back to summary
                                        selection = "Summary"
                                    } catch {
                                        print(error)
                                    }
                                }
                            }) {
                                Text("Save meal")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    // .background(context.hasChanges ? .blue : .gray)
                                    .background(.blue)
                                    .cornerRadius(10)
                            }
                        } else {
                            // Show not enough token warning
                            VStack(spacing: 10) {
                                Text("Not enough tokens")
                                    .font(.title)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                Text("You have \(localTokensRemaining ?? 0) / 4 tokens needed.")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                Text("Purchase \(appIsOwned ? "more tokens" : "a lifetime pass") in settings \(appIsOwned ? "or add an OpenAI Key " : "")to continue adding meals with AI.")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                            }.padding(10)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Add new")
            .onAppear {
                // Create new meal
                meal = Meal(emoji: "", createdAt: Date(), label: "", details: "", reviewedAt: Date(), calories: 0, protein: 0, carbohydrates: 0, fats: 0, photo: nil)
                // Set tokens remaining
                tokensRemaining { result in
                    switch result {
                    case .success(let tokens):
                        localTokensRemaining = tokens
                    case .failure(let error):
                        // Handle error if needed, for now, we'll just print it
                        print("Failed to fetch tokens: \(error.localizedDescription)")
                    }
                }
            }
            .contentShape(Rectangle()) // Ensure the gesture recognizer is aware of the full area
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -100 {
                                if(selectedTab == "Barcode") {
                                    selectedTab = "AI"
                                } else if(selectedTab == "AI") {
                                    selectedTab = "Macros"
                                }
                            } else if value.translation.width > 100 {
                                if(selectedTab == "AI") {
                                    selectedTab = "Barcode"
                                } else if(selectedTab == "Macros") {
                                    selectedTab = "AI"
                                }
                            }
                        }
                    )
                
            // Camera
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(
                    image: $imagePreview,
                    imageData: $imageData,
                    sourceType: $sourceType
                )
            }
            // Edit meal details
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
            // Edit meal date
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
}

#Preview {
    return MainTabView(selection: "Add")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
