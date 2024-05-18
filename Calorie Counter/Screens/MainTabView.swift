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
    @State private var mealDescription: String = ""

    init(selection: String?) {
        let hasShownWelcomeScreen = UserDefaults.standard.bool(forKey: "hasShownWelcomeScreen")
        _showWelcomeScreen = State(initialValue: !hasShownWelcomeScreen)
        _selection = State(initialValue: selection ?? "Summary")
    }

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                SummaryView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Summary")
                    }.tag("Summary")

                AddView(selection: $selection, navigateToProcessing: $navigateToProcessing, mealDescription: $mealDescription)
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
                destination: ProcessingView(mealDescription: mealDescription) {
                    selection = "Summary"
                }.modelContainer(for: [Meal.self]),
                isActive: $navigateToProcessing,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        }
        .sheet(isPresented: $showWelcomeScreen) {
            WelcomeView(showWelcomeScreen: $showWelcomeScreen)
        }
        .modelContainer(for: [Weight.self, Meal.self])
    }
}

#Preview {
    MainTabView(selection: nil)
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}
