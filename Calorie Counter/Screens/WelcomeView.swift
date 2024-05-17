//
//  WelcomeView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/15/24.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcomeScreen: Bool

    var body: some View {
        VStack {
            Spacer()
            
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 185, height: 185)
                .clipShape(RoundedRectangle(cornerRadius:10))
                .shadow(color: Color(UIColor.systemGray2), radius: 15)
            
            Text("Welcome to Jim's Calorie Counter")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical, 20)
            
            Text("Inspired by my personal weight loss journey, this app helps you track your nutrition quickly and securely, on-device.\n\nYou can add meals by taking a photo, describing them, or scanning their barcode. See diet summaries for any given day. Set nutrition goals, and track your weight.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 40)
            
            Button(action: {
                // Set the flag to true and dismiss the welcome screen
                UserDefaults.standard.set(true, forKey: "hasShownWelcomeScreen")
                showWelcomeScreen = false
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
        WelcomeView(showWelcomeScreen: .constant(true))
    }
}
