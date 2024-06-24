//
//  PurchaseView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 6/20/24.
//

import SwiftUI

struct Feature: View {
    var title: String
    var details: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("✅")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(width:20, height: 28, alignment: .top)
                .padding(.top, 5)
                .padding(.bottom, 10)
            VStack(spacing:5) {
                Text(title)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(details)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                
            }
        }
    }
}

func Testimonial(quote: String) -> some View {
        VStack(spacing: 8) {
            Text("“\(quote)”")
                .italic()
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .multilineTextAlignment(.center)
            
            Text("Another satisfied, paying customer.")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(width: UIScreen.main.bounds.width - 150)
        .padding(15)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .shadow(color: .black.opacity(0.1), radius: 5)
        .rotationEffect(.degrees(0.5))
    
}

struct PurchaseView: View {
    @StateObject var iapManager = InAppPurchaseManager()
    
    @Binding var showPaywall: Bool
    @Binding var appIsOwned: Bool
    
    @State private var localTokensRemaining: Int = 0


    init(showPaywall: Binding<Bool>, appIsOwned: Binding<Bool>) {
        self._showPaywall = showPaywall
        self._appIsOwned = appIsOwned
        iapManager.fetchProducts()
    }
    
    var body: some View {
        VStack(spacing:10) {
                VStack(spacing:0) {
                    Text(localTokensRemaining > 0 ? "Your free trial will end soon." : "Your free trial has ended")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                
                    HStack (alignment: .center, spacing: 0) {
                        Text("You have ")
                            .foregroundColor(.black.opacity(0.65))
                        Text("\(localTokensRemaining)/100")
                            .fontWeight(.semibold)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        Text(" tokens remaining!")
                            .foregroundColor(.black.opacity(0.65))
                    }
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
                }
            
            VStack(spacing: 5) {
                Text("UPGRADE NOW AND RECEIVE:")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.45))
                    .fontWeight(.medium)
                VStack(spacing:20) {
                    Feature(title: "Access to all features", details: "Disable usage analytics + add an OpenAI key")
                    Feature(title: "Guaranteed lifetime access", details: "No ads or monthly subscriptions ever.")
                    if let product = iapManager.availableProducts.first(where: { $0.productIdentifier == "com.logmeals.1000tokens"}) {
                        Feature(title: "1,000 free tokens for Months of AI", details: "Don’t have an OpenAI Key? Use the 1,000 included tokens instead. Enough for 250 meals. More available for \(formattedPrice(for: product))/1,000.")

                    }
                    Feature(title: "1:1 VIP Support", details: "Get Jim’s cell phone number, who lost over 125lbs. Facetime, text, or call whenever.")
                }
                .padding(10)
            }
            
            Spacer()
            // Sliding testimonials
            ScrollView(.horizontal) {
                HStack (alignment: .top, spacing:20) {
                    Testimonial(quote: "Just logged my first meal this morning, holy s**t this is good.")
                    Testimonial(quote: "This app is amazing so real to switch over to this away from Lose It.")
                    Testimonial(quote: "Really love how clean the app is :) ...the design feels like iOS")
                }.padding(10)
            }
            
                Spacer()
                
                // Purchase button
                if let product = iapManager.availableProducts.first(where: { $0.productIdentifier == "com.logmeals.lifetimeaccess" || $0.productIdentifier == "com.logmeals.ogpurchase" }) {
                    Button(action: {
                        iapManager.buyProduct(product: product)
                    }) {

                        HStack (spacing: 10) {
                                Text("Purchase life-time access")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("-")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("\(formattedPrice(for: product))")
                                    .foregroundColor(.white.opacity(0.75))
                                    .font(.system(size: 20, weight: .semibold))
                        }
                        .padding(20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(10)
                } else {
                    Text("Loading...")
                        .padding()
                }

        }
        .background(.white)
        .padding(10)
        .onChange(of: iapManager.receiptData) { newReceiptData in
            if let receiptData = newReceiptData {
                iapManager.sendReceiptToServer(receiptData: receiptData)
                // Mark purchase as completed
                print("Purchase completed:")
                // Set app as owned
                appIsOwned = true
                // Close sheet / Navigate back
                showPaywall = false
                // TODO: Add thank you screen + token stacking animation +1,000
            }
        }
    }
}

#Preview {
    PurchaseView(showPaywall: .constant(false), appIsOwned: .constant(false))
}
