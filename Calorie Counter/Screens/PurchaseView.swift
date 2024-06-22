//
//  PurchaseView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 6/20/24.
//

import SwiftUI

import SwiftUI

extension UIColor {
    static let scaleBlue = UIColor(red: 235/255, green: 245/255, blue: 255/255, alpha: 1.0)
}

extension Color {
    static let scaleBlue = Color(UIColor.scaleBlue)
}

struct Feature: View {
    var title: String
    var details: String
    
    var body: some View {
        HStack {
            Text("✅")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(width:20, height: 28, alignment: .top)
                .padding(.bottom, 10)
            VStack {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(details)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct PurchaseView: View {
    @StateObject var iapManager = InAppPurchaseManager()
    
    @State private var purchaseCompleted: Bool

    init() {
        let purchasedProductIds = UserDefaults.standard.stringArray(forKey: "purchasedProductIds")
        _purchaseCompleted = State(initialValue: purchasedProductIds?.contains("com.logmeals.lifetimeaccess") ?? false)
    }
    
    var body: some View {
        VStack(spacing:0) {
            Spacer()
            Image("Weight")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.top, 15)
                .padding(.bottom, -15)
        
            VStack(spacing: 0) {
                
                // Information text
                VStack(alignment: .leading, spacing: 10) {
                    Text("Easily track your diet. No ads or subscriptions.")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    Feature(title: "VIP Text, Call, and Facetime support", details: "Get Jim’s cell phone number, who lost over 125lbs")
                    Feature(title: "Private and Unlimited", details: "Disable usage analytics + add OpenAI API Key")
                    Feature(title: "No API Key? 1,000 tokens included", details: "Estimated ~3 months supply")
                
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Customer review
                // TODO: To sliding testimonials
                HStack {
                    VStack(spacing: 8) {
                        Text("“This app is incredible. I love how much it feels like Apple. And no ads!!!”")
                            .italic()
                            .padding(.horizontal)
                            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .multilineTextAlignment(.center)
                        
                        Text("Another satisfied, paying customer.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(color: .black.opacity(0.1), radius: 5)
                    .rotationEffect(.degrees(0.5))
                }.padding(20)
                Spacer()
                
                // Purchase button
                if let product = iapManager.availableProducts.first(where: { $0.productIdentifier == "com.logmeals.lifetimeaccess" }) {
                    Button(action: {
                        if(!purchaseCompleted) {iapManager.buyProduct(product: product)}
                    }) {

                        HStack (spacing: 10) {
                            if(purchaseCompleted) {
                                Text("Purchase completed")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                                Text("-")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Enjoy!")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                            } else {
                                Text("Buy Lifetime Access")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("-")
                                    .foregroundColor(.white.opacity(0.5))
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("\(product.price)")
                                    .foregroundColor(.white.opacity(0.75))
                                    .font(.system(size: 20, weight: .semibold))
                            }
                        }
                        .padding(20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(!purchaseCompleted ? .blue : .green)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(10)
                } else {
                    Text("Loading...")
                        .padding()
                }
                
                
                // Restore purchase button
                Button(action: {
                    // Action to restore purchase
                    
                }) {
                    Text("Already purchased? Tap here to restore")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .background(Color.scaleBlue.ignoresSafeArea())
        }
        .background(.black.gradient)
        .onChange(of: iapManager.receiptData) { newReceiptData in
            if let receiptData = newReceiptData {
                iapManager.sendReceiptToServer(receiptData: receiptData)
                // Mark purchase as completed
                print("Purchase completed:")
                purchaseCompleted = true
                // TODO: Navigate back to summary
                // navigateBackToSummary()
                // TODO: Add thank you screen + token stacking animation +1,000
            }
        }
    }
}

#Preview {
    PurchaseView()
}
