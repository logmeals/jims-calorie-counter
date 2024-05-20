//
//  MainView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var showWelcomeScreen: Bool
    @State private var selection: String
    @State private var navigateToProcessing: Bool = false
    @State private var navigateToMeal: Bool = false
    @State private var barcode: String = ""
    @State private var mealDescription: String = ""
    @State private var imageData: Data?
    // TODO: Fix exclamation point?
    @State private var mealId: UUID

    init(selection: String?) {
        let hasShownWelcomeScreen = UserDefaults.standard.bool(forKey: "hasShownWelcomeScreen")
        _showWelcomeScreen = State(initialValue: !hasShownWelcomeScreen)
        _selection = State(initialValue: selection ?? "Summary")
        mealId = UUID()
    }

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                SummaryView(navigateToMeal: $navigateToMeal, mealId: $mealId)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Summary")
                    }.tag("Summary")

                AddView(barcode: $barcode, selection: $selection, navigateToProcessing: $navigateToProcessing, mealDescription: $mealDescription, imageData: $imageData)
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("Add new")
                    }.tag("Add")

                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
                    .tag("Settings")
            }
            NavigationLink(
                destination: ProcessingView(barcode: $barcode, mealDescription: $mealDescription, imageData: $imageData) {
                    selection = "Summary"
                },
                isActive: $navigateToProcessing,
                label: {
                    EmptyView()
                }
            )
            .hidden()
            
            NavigationLink(
                destination: MealView(mealId: mealId) {
                    selection = "Summary"
                },
                isActive: $navigateToMeal,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        }
        .sheet(isPresented: $showWelcomeScreen) {
            WelcomeView(showWelcomeScreen: $showWelcomeScreen)
        }
    }
}

#Preview {
    MainTabView(selection: nil)
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
