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

    @State private var showingBarcodeScanner: Bool = false
    @Binding var barcode: String
    
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
                                sourceType = .camera
                                showingImagePicker.toggle()
                        }, grayValue: false)
                        settingsRow(title: "Select meal photo from camera roll", imageName: "Photo", lastRow: nil, gray: false, danger: nil, onTap: {_ in
                                // Activate camera roll
                                sourceType = .photoLibrary
                                showingImagePicker.toggle()
                        }, grayValue: false)
                        settingsRow(title: "Describe your meal", imageName: "Chat", lastRow: false, gray: false, danger: nil, onTap: {_ in
                                showingDescribeMealAlert.toggle()
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
                        
                        settingsRow(title: "Scan barcode", imageName: "Barcode", lastRow: true, gray: nil, danger: nil, onTap: {_ in
                            showingBarcodeScanner.toggle()
                        }, grayValue: false)
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
                    sourceType: $sourceType
                )
            }
            .onChange(of: imageData) { _ in
                if let imageData = imageData {
                    // TODO: Optionally, prompt for description based on preferences
                    // Navigate to processing
                    navigateToProcessing = true
                }
            }
            // Barcode scanner
            .sheet(isPresented: $showingBarcodeScanner) {
                VStack(spacing:25) {
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
                        // Close barcode scanner
                        showingBarcodeScanner = false
                        // Open processing page
                        navigateToProcessing = true
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 4)
                    )
                }.padding()
            }
        }
    }
}

#Preview {
    return MainTabView(selection: "Add")
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
