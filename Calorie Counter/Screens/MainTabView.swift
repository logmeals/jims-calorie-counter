//
//  MainView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var showWelcomeScreen: Bool

    init() {
         // Check if the welcome screen has been shown before
         let hasShownWelcomeScreen = UserDefaults.standard.bool(forKey: "hasShownWelcomeScreen")
         _showWelcomeScreen = State(initialValue: !hasShownWelcomeScreen)
     }
    

    var body: some View {
        TabView {
            SummaryView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Summary")
                }
            
            AddView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add new")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .sheet(isPresented: $showWelcomeScreen) {
            WelcomeView(showWelcomeScreen: $showWelcomeScreen)
        }
        .modelContainer(for: Meal.self)
    }
}


struct AddView: View {
    var body: some View {
        Text("Add Meal Page")
            .font(.largeTitle)
            .foregroundColor(.green)
            .background(Color(UIColor.systemGray6))
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings Page")
            .font(.largeTitle)
            .foregroundColor(.red)
            .background(Color(UIColor.systemGray6))
    }
}

#Preview {
    return MainTabView()
        .modelContainer(for: Meal.self, inMemory: true)
}

