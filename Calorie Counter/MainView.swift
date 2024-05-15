//
//  MainView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct MainView: View {
    @State private var showingWelcomeView = true

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
        .sheet(isPresented: $showingWelcomeView) {
            WelcomeView()
        }
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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

