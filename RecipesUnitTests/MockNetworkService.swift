//
//  MockNetworkService.swift
//  RecipesTests
//
//  Created by Romaric Allahramadji on 8/7/24.
//

import Foundation
@testable import Recipes

 class MockNetworkService: NetworkServiceProtocol {
    var shouldReturnInvalidRecipes = false
     var shouldReturnInvalidDetails = false
     var shouldReturnEmptyResponse = false
     var getMockData = false
      var mockResponse: Data?
    func fetchData<T>(endPoint: String) async throws -> T where T: Decodable {
        if getMockData {
            print("Calling mockDetails()")
            mockDetails()
        }
        if shouldReturnEmptyResponse {
               let emptyResponse = ["meals": []]  // Simulate empty valid response
               let jsonData = try JSONSerialization.data(withJSONObject: emptyResponse)
               return try JSONDecoder().decode(T.self, from: jsonData)
           }
        guard let mockData = mockResponse else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: mockData)
    }
     func mockDetails() {
         if shouldReturnInvalidDetails {
             do {
                 mockResponse = try JSONEncoder().encode(RecipeDetailsModel(
                    recipeName: "",
                    instructions: "",
                    recipeThumbnailURL: "",
                    recipeID: "",
                    ingredients: [],
                    measurements: []
                 ))
                 print("Mocked invalid details: \(mockResponse != nil)")
             } catch {
                 print("Error encoding invalid details: \(error.localizedDescription)")
             }
         } else {
             let mockData: [String: Any] = [
                "meals": [[
                    "strMeal": "Apam balik",
                    "strInstructions": "Test Instructions",
                    "strMealThumb": "https://example.com/image.jpg",
                    "idMeal": "53049",
                    "strIngredient1": "Ingredient 1",
                    "strMeasure1": "1 cup",
                    "strIngredient2": "Ingredient 2",
                    "strMeasure2": "2 tbsp"
                ]]
             ]
             do {
                 mockResponse = try JSONSerialization.data(withJSONObject: mockData)
                 print("Mocked valid details: \(mockResponse != nil)")
             } catch {
                 print("Error encoding valid details: \(error.localizedDescription)")
             }
         }
     }
    public func fetchRecipes(category: String) async throws -> [Recipe] {
        // Read test scenario from environment variable
        let scenario = ProcessInfo.processInfo.environment["UI_TEST_SCENARIO"]

        switch scenario {
        case "loading":
            // Simulate delay for loading indicator
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            return mockValidRecipes()

        case "error":
            // Throw error to trigger alert
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Server request failed."])

        case "empty":
            return [] // Empty list for empty state

        default:
            // Handle invalid recipe condition if set
            if shouldReturnInvalidRecipes {
                return [
                    Recipe(id: "", name: "", thumbnailURL: ""),
                    Recipe(id: "2", name: "", thumbnailURL: "https:")
                ]
            } else {
                return mockValidRecipes() // Default to valid recipes (success scenario)
            }
        }
    }

    public func fetchRecipeDetails(id: String) async throws -> RecipeDetailsModel {
        let scenario = ProcessInfo.processInfo.environment["UI_TEST_SCENARIO"]

        if scenario == "error" {
            throw NSError(domain: "TestError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to load recipe details."])
        }

        if shouldReturnInvalidDetails {
            // Return invalid recipe details
            return RecipeDetailsModel(
                recipeName: "", // Empty name makes it invalid
                instructions: "",
                recipeThumbnailURL: "",
                recipeID: "",
                ingredients: [],
                measurements: []
            )
        } else {
            // Return valid recipe details
            return RecipeDetailsModel(
                recipeName: "Apam balik",
                instructions: "Test Instructions",
                recipeThumbnailURL: "https://example.com/image.jpg",
                recipeID: id,
                ingredients: ["Ingredient 1", "Ingredient 2"],
                measurements: ["1 cup", "2 tbsp"]
            )
        }
    }

    private func mockValidRecipes() -> [Recipe] {
        return [
            Recipe(id: "1", name: "Pasta", thumbnailURL: "https://example.com/pasta.jpg"),
            Recipe(id: "2", name: "Pizza", thumbnailURL: "https://example.com/pizza.jpg")
        ]
    }
}
