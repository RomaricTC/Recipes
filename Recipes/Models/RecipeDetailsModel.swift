//
//  RecipeDetailsModel.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/7/24.
//

import Foundation

struct RecipeDetailsModel: Identifiable, Codable {
    let recipeName: String
    let instructions: String
    let recipeThumbnailURL: String
    let recipeID: String
    let ingredients: [String]
    let measurements: [String]
    var id: String {
        recipeID
    }
    enum CodingKeys: String, CodingKey {
        case recipeName = "strMeal"
        case instructions = "strInstructions"
        case recipeThumbnailURL = "strMealThumb"
        case recipeID = "idMeal"
    }
    init(recipeName: String, instructions: String,
         recipeThumbnailURL: String, recipeID: String,
         ingredients: [String], measurements: [String]) {
        self.recipeName = recipeName
        self.instructions = instructions
        self.recipeThumbnailURL = recipeThumbnailURL
        self.recipeID = recipeID
        self.ingredients = ingredients
        self.measurements = measurements
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        recipeName = try container.decode(String.self, forKey: .recipeName)
        instructions = try container.decode(String.self, forKey: .instructions)
        recipeThumbnailURL = try container.decode(String.self, forKey: .recipeThumbnailURL)
        recipeID = try container.decode(String.self, forKey: .recipeID)
        var dynamicIngredients: [String] = []
        var dynamicMeasurements: [String] = []
        let containerDic = try decoder.singleValueContainer()
        let recipeDic = try containerDic.decode([String: String?].self)
        var index = 1
        while true {
            let ingredientKey = "strIngredient\(index)"
            let measureKey = "strMeasure\(index)"
            if let ingredient = recipeDic[ingredientKey] as? String,
               let measurements = recipeDic[measureKey] as? String {
                if !ingredient.isEmpty {
                    dynamicIngredients.append(ingredient)
                    dynamicMeasurements.append(measurements)
                }
            } else {
                break
            }
            index += 1
        }
        ingredients = dynamicIngredients
        measurements = dynamicMeasurements
    }
}
