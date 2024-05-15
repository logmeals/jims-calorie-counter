//
//  WelcomeView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "applelogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.bottom, 40)
            
            Text("Welcome to Jim's Calorie Counter")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            Text("Inspired by my personal weight loss journey, this app helps you track your nutrition quickly and securely, on-device.\n\nYou can add meals by taking a photo, describing them, or scanning their barcode. See diet summaries for any given day. Set nutrition goals, and track your weight.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 40)
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "hasSeenWelcomeScreen")
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct WelcomeView_Preview: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
