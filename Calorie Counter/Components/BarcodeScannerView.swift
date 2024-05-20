//
//  BarcodeScannerView.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/20/24.
//

import SwiftUI
import AVFoundation
import Foundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView

        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                
                // Vibration for feedback
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.didFindCode(stringValue)
            }
        }
    }

    var didFindCode: (String) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .code128] // Add more types as needed
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// Define the necessary data structures for parsing JSON response
struct OpenFoodFactsResponse: Codable {
    let code: String
    let product: Product
}

struct Product: Codable {
    let product_name: String?
    let nutriments: Nutriments?
}

struct Nutriments: Codable {
    let energy_kcal: Double?
    let proteins: Double?
    let carbohydrates: Double?
    let fat: Double?
}

func fetchProductInfo(upc: String, completion: @escaping (String?, String?, Double?, Double?, Double?, Double?) -> Void) {
    // Construct the URL
    let urlString = "https://world.openfoodfacts.org/api/v0/product/\(upc).json"
    guard let url = URL(string: urlString) else {
        completion(nil, nil, nil, nil, nil, nil)
        return
    }
    
    // Create the URLRequest and add the User-Agent header
    var request = URLRequest(url: url)
    request.setValue("Jim's Calorie Counter - iOS - Version 1.0 - www.jims.cx", forHTTPHeaderField: "User-Agent")



    // Create the URLSession data task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error:")
            print(error)
            completion(nil, nil, nil, nil, nil, nil)
            return
        }

        // Parse the JSON response
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(OpenFoodFactsResponse.self, from: data)
            print("Got response!")
            print(response)
            let product = response.product

            // Extract relevant details
            let label = product.product_name
            let description = product.product_name // You can change this if there's a more appropriate field
            let calories = product.nutriments?.energy_kcal 
            let protein = product.nutriments?.proteins
            let carbohydrates = product.nutriments?.carbohydrates
            let fat = product.nutriments?.fat

            // Call the completion handler with the extracted details
            completion(label, description, calories, protein, carbohydrates, fat)
        } catch {
            print("Error")
            print(error)
            completion(nil, nil, nil, nil, nil, nil)
        }
    }

    // Start the network request
    task.resume()
}
