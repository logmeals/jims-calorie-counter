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
    print("Using OpenAI API")
    // Ensure at least one of mealDescription or imageData is provided
    guard mealDescription != nil || imageData != nil else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No meal description or image provided."])))
        return
    }

    var prompt = """
    You are an expert nutritionist. Based on an item's description, and/or image provided, your task is to estimate its nutritional content (being the sum of the food+drinks pictured) as best as you can and describe it concisely and accurately. Provide a short label (16 characters or less) that best describes the meal, alongside an emoji that describes the meal, and then estimate the calories, protein, carbohydrates, and fats in JSON format. Answer confidently and concisely! If a non-food image/description is provided or you aren't able to provide an estimate, return an error and do not use the JSON format provided (or else your error might not be understood).
    
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

    if mealDescription != nil && mealDescription != "" {
        prompt += "\n\nDescription: \(mealDescription ?? "")"
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
        var compressionQuality = UserDefaults.standard.double(forKey: "imageCompression")
        
        if compressionQuality > 1 {
            compressionQuality = 1
        }
        if compressionQuality == 0 {
            compressionQuality = 0.1
        }
        if let base64Image = compressAndEncodeImage(image, compressionQuality: compressionQuality) {
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
        print("Error: Sending image failed, uploading text prompt.")
        content = prompt
    }

    
    let parameters: [String: Any] = [
        "model": "gpt-4", // Replace with your desired model
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
            let jsonResponseString = String(data: data, encoding: .utf8) ?? "No data"
            print("OpenAI JSON Response: \(jsonResponseString)")
            
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
            print("Error parsing JSON: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    task.resume()
}

func callCloudAIAPI(mealDescription: String? = nil, imageData: Data? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    print("Using Cloud AI API")
    // Ensure at least one of mealDescription or imageData is provided
    guard mealDescription != nil || imageData != nil else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No meal description or image provided."])))
        return
    }

    // Fetch userId from UserDefaults
    if let userId = UserDefaults.standard.string(forKey: "userId"), !userId.isEmpty {
        print("User ID: \(userId)")
        // Proceed with the API call using the existing userId
        callEstimateAPI(userId: userId, mealDescription: mealDescription, imageData: imageData, completion: completion)
    } else {
        // Create userId by making a POST request to 'https://api.jims.cx/create-user-id'
        createUserAndFetchId { result in
            switch result {
            case .success(let userId):
                // Store userId in UserDefaults
                UserDefaults.standard.set(userId, forKey: "userId")
                print("Created new User ID: \(userId)")
                // Proceed with the API call using the new userId
                callEstimateAPI(userId: userId, mealDescription: mealDescription, imageData: imageData, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

func createUserAndFetchId(completion: @escaping (Result<String, Error>) -> Void) {
    guard let url = URL(string: "https://api.jims.cx/create-user-id") else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for user creation"])))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }

        do {
            let jsonResponseString = String(data: data, encoding: .utf8) ?? "No data"
            print("Create User ID JSON Response: \(jsonResponseString)")
            
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let userId = jsonResponse["userId"] as? String {
                completion(.success(userId))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
            }
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}

private func callEstimateAPI(userId: String, mealDescription: String?, imageData: Data?, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    guard let url = URL(string: "https://api.jims.cx/estimate") else {
        print("Error: Invalid URL")
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    // Prepare the request body
    var requestBody: [String: Any] = ["userId": userId, "gptModel": "gpt-4o"]

    if let mealDescription = mealDescription, !mealDescription.isEmpty {
        requestBody["details"] = mealDescription
    }

    if let imageData = imageData {
        requestBody["imageBase64"] = imageData.base64EncodedString()
    }

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        print("Error encoding JSON body: \(error.localizedDescription)")
        completion(.failure(error))
        return
    }

    // Perform the network request
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
            let jsonResponseString = String(data: data, encoding: .utf8) ?? "No data"
            print("Cloud AI JSON Response: \(jsonResponseString)")
            
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Ensure the required keys are present
                if let label = jsonResponse["label"] as? String,
                   let emoji = jsonResponse["emoji"] as? String,
                   let calories = jsonResponse["calories"] as? Int,
                   let protein = jsonResponse["protein"] as? Int,
                   let carbohydrates = jsonResponse["carbohydrates"] as? Int,
                   let fats = jsonResponse["fats"] as? Int {
                    let result: [String: Any] = [
                        "label": label,
                        "emoji": emoji,
                        "calories": calories,
                        "protein": protein,
                        "carbohydrates": carbohydrates,
                        "fats": fats
                    ]
                    completion(.success(result))
                } else {
                    print("Error: Missing keys in response")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing keys in response"])))
                }
            } else {
                print("Error: Unable to parse JSON response")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse JSON response"])))
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    task.resume()
}

func callAIAPI(mealDescription: String? = nil, imageData: Data? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let openAIAPIKey = UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
    
    if !openAIAPIKey.isEmpty {
        callOpenAIAPI(mealDescription: mealDescription, imageData: imageData, completion: completion)
    } else {
        callCloudAIAPI(mealDescription: mealDescription, imageData: imageData, completion: completion)
    }
}

func tokensRemaining(completion: @escaping (Result<Int, Error>) -> Void) {
    guard let userId = UserDefaults.standard.string(forKey: "userId"), !userId.isEmpty else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found in UserDefaults"])))
        return
    }
    
    guard let url = URL(string: "https://api.jims.cx/tokens") else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = ["userId": userId]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        completion(.failure(error))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let tokens = jsonResponse["tokens"] as? Int {
                completion(.success(tokens))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    task.resume()
}
