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
                .clipShape(RoundedRectangle(cornerRadius:24))
                .shadow(color: Color(UIColor.systemGray2), radius: 20)
                .padding(.bottom, 20)
            
            VStack (spacing: 10) {
            
                    Text("Welcome!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("About your free trial")
                        .font(.title2)
                        .fontWeight(.medium)
                        .opacity(0.55)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                
                Text("You’ll get 100 tokens, enough to add 25 meals with AI. Scanning barcodes or adding macros does not take tokens.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(UIColor.systemGray))
                
                Text("At any given time, you can upgrade from settings to unlock all features.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(UIColor.systemGray))
                
                Text("If you have questions, join our Discord and send me a message for support!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(UIColor.systemGray))
                
                Text("- Jim Bisenius, Founder")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(UIColor.systemGray))
                
            }.padding(.horizontal)
            
            Spacer()
            
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
