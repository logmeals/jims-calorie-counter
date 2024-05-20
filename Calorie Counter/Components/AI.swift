//
//  AI.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/18/24.
//

import SwiftUI
import Foundation

func compressAndEncodeImage(_ image: UIImage, compressionQuality: CGFloat) -> String? {
    // Compress the image
    guard let compressedImageData = image.jpegData(compressionQuality: compressionQuality) else {
        return nil
    }
    
    // Encode the compressed image data to a base64 string
    return compressedImageData.base64EncodedString()
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let role: String
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

func callOpenAIAPI(mealDescription: String? = nil, imageData: Data? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    // Ensure at least one of mealDescription or imageData is provided
    guard mealDescription != nil || imageData != nil else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No meal description or image data provided."])))
        return
    }

    var prompt = """
    You are an expert nutritionist. Based on the description of a meal and/or an image provided, your task is to estimate its nutritional content as best as you can and describe it concisely and accurately. Provide a short label (16 characters or less) that best describes the meal, alongside an emoji that describes the meal, and then estimate the calories, protein, carbohydrates, and fats in JSON format. Answer confidently and concisely! If a non-food image is attached or described, return an error and do not use the JSON format provided (or else your error might not be understood).
    
    \nResponse format:
    {
        "label": "Short label",
        "emoji": "A single emoji that best represents this meal",
        "calories": "Calorie estimate",
        "protein": "Protein estimate in grams",
        "carbohydrates": "Carbohydrates estimate in grams",
        "fats": "Fats estimate in grams"
    }

    Example:
    Description: Grilled chicken breast with quinoa and steamed broccoli
    Response:
    {
        "label": "Chicken Meal",
        "emoji": "🍗",
        "calories": 450,
        "protein": 35,
        "carbohydrates": 40,
        "fats": 15
    }

    Now, process the following:\n
    """

    if let mealDescription = mealDescription {
        prompt += "\n\nDescription: \(mealDescription)"
    }

    guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
        print("Error: Invalid URL")
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Ensure Open AI API Key exists
    let openAIAPIKEY = UserDefaults.standard.string(forKey: "openAIAPIKey")
    if openAIAPIKEY == "" {
        print("Error: OpenAI API Keys not present.")
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "OpenAI API Keys not present."])))
        return
    }
    
    request.addValue("Bearer \(openAIAPIKEY ?? "")", forHTTPHeaderField: "Authorization")
    
    var content: Any

    if let imageData = imageData, let image = UIImage(data: imageData) {
        if let base64Image = compressAndEncodeImage(image, compressionQuality: 0.35) {
            content = [
                [
                    "type": "text",
                    "text": prompt
                ],
                [
                    "type": "image_url",
                    "image_url": [
                        "url": "data:image/jpeg;base64,\(base64Image)"
                    ]
                ]
            ]
        } else {
            // Upload raw image if compression fails
            print("Compression failed uploading raw image")
            content = [
                [
                    "type": "text",
                    "text": prompt
                ],
                [
                    "type": "image_url",
                    "image_url": [
                        "url": "data:image/jpeg;base64,\(imageData.base64EncodedString())"
                    ]
                ]
            ]
        }
    } else {
        content = prompt
    }

    
    let parameters: [String: Any] = [
        "model": "gpt-4o", // Replace with your desired model
        "messages": [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": content]
            
        ],
        "max_tokens": 256,
        "temperature": 1.0,
        "top_p": 1.0,
        "frequency_penalty": 0,
        "presence_penalty": 0
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    } catch {
        print("Error encoding JSON body: \(error.localizedDescription)")
        completion(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("Error: No data received!")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            print("Data received")
            print(data)
            let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            if let firstChoice = response.choices.first {
                let responseData = firstChoice.message.content.data(using: .utf8)!
                let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
                completion(.success(jsonResponse ?? [:]))
            } else {
                print("Error: No choices in response!")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No choices in response"])))
            }
        } catch {
            print("Error decoding JSON response: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}
