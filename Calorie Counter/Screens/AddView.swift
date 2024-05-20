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

    @Binding var selection: String
    @Binding var navigateToProcessing: Bool
    @Binding var mealDescription: String
    @Binding var imageData: Data?


    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    /*
                    settingsSection(header: "Weight") {
                        settingsRow(title: "Enter your weight manually", imageName: "Received", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Pair smart-scale", imageName: "Scale", lastRow: true, gray: nil, danger: nil, onTap: nil)
                    }
                    */
                    
                    settingsSection(header: "Meal") {
                        settingsRow(title: "Take a photo of your meal", value: nil, imageName: "Camera", lastRow: nil, gray: false, danger: nil, onTap: {_ in
                                // Activate camera
                                sourceType = .camera
                                showingImagePicker.toggle()
                        }, grayValue: false)
                        settingsRow(title: "Select meal photo from camera roll", imageName: "Photo", lastRow: nil, gray: nil, danger: nil, onTap: {_ in
                            // Activate camera roll
                            sourceType = .photoLibrary
                            showingImagePicker.toggle()
                        }, grayValue: false)
                        settingsRow(title: "Describe your meal", imageName: openAIAPIKey == "" ? "Lock" : "Chat", lastRow: true, gray: openAIAPIKey == "", danger: nil, onTap: {_ in
                                if openAIAPIKey != "" {
                                    showingDescribeMealAlert.toggle()
                                }
                            }, grayValue: false
                        ).onAppear {
                            openAIAPIKey = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
                        }
                                .alert("Describe your meal", isPresented: $showingDescribeMealAlert) {
                                    TextField("ex: A 12ct chicken nugget meal from Chickfila", text: $mealDescription)
                                    Button("Cancel", action: {
                                        showingDescribeMealAlert.toggle()
                                    })
                                    Button("Save meal", action: {
                                        let desiredMealDescription = $mealDescription.wrappedValue
                                        if desiredMealDescription != "" {
                                            // TODO: Move to Processing page?
                                            navigateToProcessing = true
                                        }
                                    })
                                } message: {
                                    Text("Enter as much information as you can. ex: What and how much you ate, from where, modifications, etc")
                                }
                        
                        // settingsRow(title: "Scan barcode", imageName: "Barcode", lastRow: true, gray: nil, danger: nil, onTap: nil)
                    }
                    
                    // Display warning if OpenAI API Key is not yet added.
                    if(openAIAPIKey == "") {
                        HStack(spacing: 20) {
                            Text("🛑")
                                .font(. system(size: 48))
                            VStack(spacing:5) {
                                Text("Stop!")
                                    .font(. system(size: 18))
                                    .foregroundColor(Color.red)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                Text("Before you can add meals, you need to add your OpenAI API Key in settings.")
                                    .font(. system(size: 14))
                                    .foregroundColor(Color.red.opacity(0.8))
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.red), lineWidth: 1)
                        )
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Add new")
            // Camera
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(
                    image: $imagePreview,
                    imageData: $imageData,
                    sourceType: sourceType
                )
            }
            .onChange(of: imageData) { _ in
                if let imageData = imageData {
                    // TODO: Optionally, prompt for description based on preferences
                    // Navigate to processing
                    navigateToProcessing = true
                }
            }
        }
    }
}

#Preview {
    return MainTabView(selection: "Add")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
