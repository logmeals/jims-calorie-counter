//
//  SettingsView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/17/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject var iapManager = InAppPurchaseManager()
    
    @Binding var showPaywall: Bool
    @Binding private var appIsOwned: Bool

    @State private var askForDescription: Bool = true
    @State private var mealsToShow: String = "3"
    @State private var mealReminders: Bool = false
    @State private var sendAnonymousData: Bool = true
    
    @State private var newGoal: String = ""
    @State private var calorieGoal: Int = 0
    // @State private var weightGoal: Int = 0
    @State private var proteinGoal: Int = 0
    @State private var carbohydratesGoal: Int = 0
    @State private var fatsGoal: Int = 0
    
    @State private var editingGoal: String = ""
    // Computed property to check if editingGoal is not empty
    private var isEditing: Bool {
        return !editingGoal.isEmpty
    }
    
    @State private var restoringPurchases: Bool = false

    @State private var editingOpenAIKey: Bool = false
    @State private var newOpenAIKey: String = ""
    @State private var openAIKey: String = ""
    
    @State private var editingUserId: Bool = false
    @State private var newUserId: String = ""
    @State private var userId: String = ""

    @State private var localTokensRemaining: Int = 0
    
    @State private var editingImageCompression: Bool = false
    @State private var newImageCompression: String = "0.5"
    @State private var imageCompression: Double = 0.5
    
    init(showPaywall: Binding<Bool>, appIsOwned: Binding<Bool>) {
        self._showPaywall = showPaywall
        self._appIsOwned = appIsOwned
        iapManager.fetchProducts()
        
        let id = UserDefaults.standard.string(forKey: "userId") ?? ""
                
        _userId = State(initialValue: id)
    }
    
    func editGoal(goal: String) {
        editingGoal = goal
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // TODO: Add "Tap to purchaes more tokens prompt"
                    settingsSection(header: "Pro") {
                        settingsRow(title: "Tokens remaining", subtitle: appIsOwned ? "Tap to buy more!" : "Purchase lifetime access for more!", value: "\(formatNumberWithCommas(localTokensRemaining))", lastRow: nil, gray: nil, danger: nil, onTap: {_ in
                            // Disable buying more tokens until lifetime pass is owned.
                            if(!appIsOwned) {
                                // Show lifetime access paywall
                                showPaywall = true
                            } else {
                                // Purchase more tokens
                                if let product = iapManager.availableProducts.first(where: { $0.productIdentifier == "com.logmeals.1000tokens" }) {
                                    // Purchase product
                                    iapManager.buyProduct(product: product)
                                    // TODO: Add listen for receipt like on PurchaseView
                                }
                            }
                            }, grayValue: false)
                            .onAppear {
                                tokensRemaining { result in
                                    switch result {
                                    case .success(let tokens):
                                        DispatchQueue.main.async {
                                            localTokensRemaining = tokens
                                        }
                                    case .failure(let error):
                                        // Handle error if needed, for now, we'll just print it
                                        print("Failed to fetch tokens: \(error.localizedDescription)")
                                    }
                                }
                            }
    
                        
                        
                        settingsRow(title: "Purchase lifetime access", value: appIsOwned ? "You've purchased this already" : nil, lastRow: nil, gray: appIsOwned, danger: nil, onTap: {_ in
                                // Navigate to paywall
                                print("Navigate to paywall")
                                if(!appIsOwned) { showPaywall = true }
                            }, grayValue: false
                        )
                        
                        
                        settingsRow(title: "Restore purchases", value: "", lastRow: true, gray: nil, danger: nil, onTap: {_ in
                                // TODO: Restore purchases
                                var receipt = iapManager.getReceiptData()
                                iapManager.sendReceiptToServer(receiptData: receipt!)
                                // Notify user restore completed
                                restoringPurchases.toggle()
                            
                                // Afterwards, re-load appIsOwned
                                let purchasedProductIds = UserDefaults.standard.stringArray(forKey: "purchasedProductIds")
                                appIsOwned = purchasedProductIds?.contains("com.logmeals.lifetimeaccess") ?? false
                            
                                // Afterwards, re-load tokens owned
                                tokensRemaining { result in
                                    switch result {
                                    case .success(let tokens):
                                        DispatchQueue.main.async {
                                            localTokensRemaining = tokens
                                        }
                                    case .failure(let error):
                                        // Handle error if needed, for now, we'll just print it
                                        print("Failed to fetch tokens: \(error.localizedDescription)")
                                    }
                                }
                            }, grayValue: false
                        )
                    }
                     
                    settingsSection(header: "Goals") {
                        settingsRow(title: "Calories", value: calorieGoal > 0 ? "\(formatNumberWithCommas(calorieGoal)) calories" : "N/A", lastRow: nil, gray: nil, danger: nil, onTap: editGoal, grayValue: calorieGoal == 0)
                            .onAppear {
                                calorieGoal = UserDefaults.standard.integer(forKey: "caloriesGoal")
                            }
                        settingsRow(title: "Protein", value: proteinGoal > 0 ? "\(proteinGoal)g" : "N/A", lastRow: nil, gray: nil, danger: nil, onTap: editGoal, grayValue: proteinGoal == 0)
                            .onAppear {
                                proteinGoal = UserDefaults.standard.integer(forKey: "proteinGoal")
                            }
                        settingsRow(title: "Carbohydrates", value: carbohydratesGoal > 0 ? "\(carbohydratesGoal)g" : "N/A", lastRow: nil, gray: nil, danger: nil, onTap: editGoal, grayValue: carbohydratesGoal == 0)
                            .onAppear {
                                carbohydratesGoal = UserDefaults.standard.integer(forKey: "carbohydratesGoal")
                            }
                        settingsRow(title: "Fats", value: fatsGoal > 0 ? "\(fatsGoal)g" : "N/A", lastRow: true, gray: nil, danger: nil, onTap: editGoal, grayValue: fatsGoal == 0)
                            .onAppear {
                                fatsGoal = UserDefaults.standard.integer(forKey: "fatsGoal")
                            }
                        //settingsRow(title: "Weight", value: "\(weightGoal)g/day", lastRow: true, gray: nil, danger: nil, onTap: nil)
                    }
                    
                    settingsSection(header: "Community") {
                        settingsRow(title: "Join our Discord Community", imageName: "Discord", lastRow: false, gray: nil, danger: nil, onTap: {_ in
                                // TODO: Redirect to join Discord Link
                            UIApplication.shared.open(URL(string: "https://discord.gg/TT8W6DfXHe")!)
                        }, grayValue: false)
                        
                        settingsRow(title: "Support", value: appIsOwned ? "984-269-8841" : "Discord", lastRow: true, gray: false, danger: false, onTap: {
                            _ in
                            // Do nothing
                        }, grayValue: true)
                        
                        // settingsRow(title: "Refer a friend, get $5!", imageName: "Gift", lastRow: true, gray: nil, danger: nil, onTap: nil)
                    }
                    
                    settingsSection(header: "Technical") {
                
                        
                        settingsRow(title: "OpenAI API Key", value: appIsOwned ? (openAIKey != "" ? "******" : "N/A") : "N/A", imageName: appIsOwned ? nil : "Lock", lastRow: false, gray: nil, danger: nil, onTap: {_ in
                            if(appIsOwned) {editingOpenAIKey = true}
                        }, grayValue: openAIKey == "")
                        .onAppear {
                            openAIKey = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
                        }
                        
                        settingsRow(title: "Send usage analytics", value: appIsOwned ? "Disabled" : "Enabled", imageName: appIsOwned ? nil : "Lock", lastRow: false, gray: nil, danger: nil, onTap: {_ in
                        }, grayValue: openAIKey == "")
                    
                        /*
                        settingsRow(title: "Image compression", value: imageCompression.description, lastRow: false, gray: nil, danger: nil, onTap: {_ in
                            editingImageCompression = true
                        }, grayValue: openAIKey == "")
                        .onAppear {
                            imageCompression = UserDefaults.standard.double(forKey: "imageCompression")
                            // If zero
                            if imageCompression == 0 {
                                // Fix
                                newImageCompression = "0.5"
                                imageCompression = 0.5
                                UserDefaults.standard.setValue(0.5, forKey: "imageCompression")
                            } else {
                                newImageCompression = imageCompression.description
                            }
                        }
                        */
                        
                        settingsRow(title: "Edit User ID", value: "*****", lastRow: false, gray: false, danger: nil, onTap: {_ in
                            // Edit User ID
                            editingUserId = true
                        }, grayValue: true)
                        .onAppear {
                            // Edit local UserID
                            userId = UserDefaults.standard.string(forKey: "userId") ?? ""
                            
                            if(userId.isEmpty) {
                                // Create userId by making a POST request to 'https://api.jims.cx/create-user-id'
                                createUserAndFetchId { result in
                                    switch result {
                                    case .success(let newUserId):
                                        // Store userId in UserDefaults
                                        UserDefaults.standard.set(newUserId, forKey: "userId")
                                        userId = newUserId
                                        // Refetch token count
                                        tokensRemaining { result in
                                            switch result {
                                            case .success(let tokens):
                                                DispatchQueue.main.async {
                                                    localTokensRemaining = tokens
                                                }
                                            case .failure(let error):
                                                // Handle error if needed, for now, we'll just print it
                                                print("Failed to fetch tokens: \(error.localizedDescription)")
                                            }
                                        }
                                    case .failure(let error):
                                        print("Failed to create new userId")
                                    }
                                }
                            }
                        }
                        
                        
                        //settingsRow(title: "Ask for description on meal photos?", value: askForDescription ? "Yes" : "No", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        //settingsRow(title: "Meals to show by default?", value: mealsToShow, lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        //settingsRow(title: "Meal reminders?", value: mealReminders ? "Enabled" : "Disabled", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        //settingsRow(title: "Send anonymous usage data?", value: sendAnonymousData ? "Enabled" : "Disabled", lastRow: true, gray: nil, danger: nil, onTap: nil)
                        
                    }
                    
                    /*
                    settingsSection(header: "Support") {
                        settingsRow(title: "Restore purchases", imageName: "Bag", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Upgrade and unlock full access", imageName: "Lightning", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Export data", imageName: "Export", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Report bug", imageName: "Bug", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Contact support", imageName: "Raft", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "View Privacy Policy / EULA", imageName: "Building", lastRow: nil, gray: nil, danger: nil, onTap: nil)
                        settingsRow(title: "Delete all data", imageName: "Garbage", lastRow: true, gray: nil, danger: true, onTap: nil)
                    }
                     */
                }
                .padding()
            }
            .alert("Edit \(editingGoal) goal", isPresented: Binding<Bool>(
                get: { self.isEditing },
                set: { newValue in
                    if !newValue {
                        self.editingGoal = ""
                    }
                })) {
                TextField("ex: 92g", text: $newGoal)
                Button("Save goal", action: {
                    let desiredGoal = Int($newGoal.wrappedValue)
                    if desiredGoal != 0 {
                        // Save new goal
                        UserDefaults.standard.set(desiredGoal, forKey: "\(editingGoal.lowercased())Goal")
                        // Update goal in macro item view immediately without refreshing view
                        if(editingGoal.lowercased() == "calories") { calorieGoal = desiredGoal ?? 0 }
                        if(editingGoal.lowercased() == "protein") { proteinGoal = desiredGoal ?? 0 }
                        if(editingGoal.lowercased() == "carbohydrates") { carbohydratesGoal = desiredGoal ?? 0 }
                        if(editingGoal.lowercased() == "fats") {fatsGoal = desiredGoal ?? 0 }
                    }
                    editingGoal = ""
                    newGoal = ""
                })
                    Button("Delete goal", action: {
                        // Update User Defaults
                        UserDefaults.standard.set(nil, forKey: "\(editingGoal.lowercased())Goal")
                        // Update goal in macro item view immediately without refreshing view
                        if(editingGoal.lowercased() == "calories") { calorieGoal = 0 }
                        if(editingGoal.lowercased() == "protein") { proteinGoal = 0 }
                        if(editingGoal.lowercased() == "carbohydrates") { carbohydratesGoal = 0 }
                        if(editingGoal.lowercased() == "fats") {fatsGoal = 0 }
                        editingGoal = ""
                        newGoal = ""
                    })
                    Button("Cancel", action: {
                        editingGoal = ""
                        newGoal = ""
                    })
            } message: {
                Text("Enter your new goal:")
            }
            .alert("Edit User ID", isPresented: $editingUserId) {
                TextField("ex: 49fd....", text: $newUserId)
                Button("Save", action: {
                    let desiredUserId = $newUserId.wrappedValue
                    if desiredUserId != "" {
                        // Save new API Key
                        UserDefaults.standard.set(desiredUserId, forKey: "userId")
                        userId = desiredUserId
                        newUserId = ""
                    }
                })
                Button("Cancel", action: {
                    editingUserId = false
                    newUserId = ""
                })
            } message: {
                Text("Don't share this or edit it unless instructed to by Jim!")
            }
            .alert("Edit OpenAI API Key", isPresented: $editingOpenAIKey) {
                TextField("ex: sk....", text: $newOpenAIKey)
                Button("Save", action: {
                    let desiredAPIKey = $newOpenAIKey.wrappedValue
                    if desiredAPIKey != "" {
                        // Save new API Key
                        UserDefaults.standard.set(desiredAPIKey, forKey: "openAIAPIKey")
                        openAIKey = desiredAPIKey
                        newOpenAIKey = ""
                    }
                })
                Button("Delete", action: {
                    // Update User Defaults
                    UserDefaults.standard.set(nil, forKey: "openAIAPIKey")
                    openAIKey = ""
                    newOpenAIKey = ""
                })
                Button("Cancel", action: {
                    editingOpenAIKey = false
                    newOpenAIKey = ""
                })
            } message: {
                Text("Keys are stored securely on your device, and are never sent to anyone besides OpenAI.")
            }
            .alert("Edit Image compression rate", isPresented: $editingImageCompression) {
                TextField("ex: 0.5", text: $newImageCompression)
                    .keyboardType(.numberPad)
                Button("Save", action: {
                    imageCompression = Double(newImageCompression ?? "0.5") ?? 0.5
                    // Max compression
                    if(imageCompression > 1) {
                        imageCompression = 1
                        newImageCompression = "1.0"
                    }
                    // Min compression
                    if(imageCompression == 0) {
                        imageCompression = 0.35
                        newImageCompression = "0.35"
                    }
                    UserDefaults.standard.set(imageCompression, forKey: "imageCompression")
                    editingImageCompression.toggle()
                })
                Button("Cancel", action: {
                    editingImageCompression.toggle()
                    newImageCompression = imageCompression.description
                })
            } message: {
                Text("1 = Highest Quality / No compression, .1 = Lowest Quality")
            }
            .alert("Purchases restored", isPresented: $restoringPurchases) {
                Button("Close", action: {
                    restoringPurchases.toggle()
                })
            } message: {
                Text("Purchases restored successfully. You may need to close and re-open your app to for updates to appear.")
            }
            
            .onChange(of: iapManager.receiptData) { newReceiptData in
                if let receiptData = newReceiptData {
                    iapManager.sendReceiptToServer(receiptData: receiptData)
                    // Mark purchase as completed
                    print("Purchase completed:")
                    // Refetch token count
                    tokensRemaining { result in
                        switch result {
                        case .success(let tokens):
                            DispatchQueue.main.async {
                                localTokensRemaining = tokens
                            }
                        case .failure(let error):
                            // Handle error if needed, for now, we'll just print it
                            print("Failed to fetch tokens: \(error.localizedDescription)")
                        }
                    }
                    // TODO: Add thank you screen + token stacking animation +1,000
                }
            }
            .background(Color(UIColor.systemGray6))
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    return SettingsView(showPaywall: .constant(false), appIsOwned: .constant(false))
}
