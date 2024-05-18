//
//  AI.swift
//  Calorie Counter
//
//  Created by Jim Bisenius on 5/18/24.
//

import Foundation

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

func callOpenAIAPIForMealDescription(mealDescription: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    let prompt = """
    You are a nutritionist AI assistant. Based on the description of a meal provided, your task is to estimate its nutritional content. Provide a short label (16 characters or less) that best describes the meal, alongisde an emoji that describes the meal, and then estimate the calories, protein, carbohydrates, and fats in JSON format.

    Description: \(mealDescription)

    Response format:
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

    Now, process the following meal description:

    Description: \(mealDescription)
    """

    guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
        print("Error: Invalid URL")
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(Keys.sandboxKey)", forHTTPHeaderField: "Authorization") // Replace with your actual API key
    
    let parameters: [String: Any] = [
        "model": "gpt-4o", // Replace with your desired model
        "messages": [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": prompt]
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
