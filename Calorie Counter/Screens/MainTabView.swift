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


    init(selection: String?) {
         // Check if the welcome screen has been shown before
         let hasShownWelcomeScreen = UserDefaults.standard.bool(forKey: "hasShownWelcomeScreen")
         _showWelcomeScreen = State(initialValue: !hasShownWelcomeScreen)
        _selection = State.init(initialValue: selection ?? "Summary")
     }
    

    var body: some View {
        TabView(selection: $selection) {
            SummaryView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Summary")
                }.tag("Summary")
            
            AddView()
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
        .sheet(isPresented: $showWelcomeScreen) {
            WelcomeView(showWelcomeScreen: $showWelcomeScreen)
        }
        .modelContainer(for: Meal.self)
    }
}

#Preview {
    return MainTabView(selection: nil)
        .modelContainer(for: [Weight.self, Meal.self], inMemory: true)
}

