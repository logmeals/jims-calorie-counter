//
//  InAppPurchases.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 6/20/24.
//

import StoreKit
import SwiftUI

class InAppPurchaseManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var availableProducts = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    @Published var receiptData: Data?

    private var productsRequest: SKProductsRequest?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }

    func fetchProducts() {
        let productIdentifiers = Set(["com.logmeals.lifetimeaccess", "com.logmeals.1000tokens"])
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.availableProducts = response.products
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products: \(error.localizedDescription)")
    }

    func buyProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User cannot make payments.")
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("Handling transaction")
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                handleFailed(transaction)
            case .restored:
                handleRestored(transaction)
            default:
                break
            }
        }
    }

    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        print("Transaction completed successfully.")
        DispatchQueue.main.async {
            self.transactionState = .purchased
            if let receiptData = self.getReceiptData() {
                self.receiptData = receiptData
                self.sendReceiptToServer(receiptData: receiptData)
            }
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }

    private func handleFailed(_ transaction: SKPaymentTransaction) {
        print("Transaction failed.")
        if let error = transaction.error as NSError? {
            print("Error: \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.transactionState = .failed
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func handleRestored(_ transaction: SKPaymentTransaction) {
        print("Transaction restored.")
        DispatchQueue.main.async {
            self.transactionState = .restored
            if let receiptData = self.getReceiptData() {
                self.receiptData = receiptData
                self.sendReceiptToServer(receiptData: receiptData)
            }
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }

    func getReceiptData() -> Data? {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else {
            return nil
        }
        return try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
    }

    func sendReceiptToServer(receiptData: Data) {
        guard let url = URL(string: "http://192.168.5.116:3001/validate-purchase") else {
            print("Error: Bad URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "receiptBase64": receiptData.base64EncodedString(options: []),
            "userId": UserDefaults.standard.string(forKey: "userId") ?? ""
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error:")
                print(error)
                return
            }

            guard let data = data else {
                print("Error: No data returned from purchase validation")
                return
            }

            do {
                let jsonResponseString = String(data: data, encoding: .utf8) ?? "No data"

                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                    if let userId = jsonResponse["userId"] as? String, !userId.isEmpty {
                        // Store userID in UserDefaults
                        UserDefaults.standard.set(userId, forKey: "userId")
                    }
                    
                    if let purchasedProductIds = jsonResponse["purchasedProductIds"] as? [String] {
                        // Store purchase IDs in UserDefaults
                        UserDefaults.standard.setValue(purchasedProductIds, forKey: "purchasedProductIds")
                    } else {
                        print("Caution: Purchases not found in response")
                    }
                } else {
                    print("Failed to parse JSON response")
                }
            } catch {
                print("Failure!")
                print(error)
            }
        }

        task.resume()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }
}
