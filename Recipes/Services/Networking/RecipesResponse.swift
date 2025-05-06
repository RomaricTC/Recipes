//
//  RecipesResponse.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 2/13/25.
//

import Foundation

struct RecipesResponse: Codable {
    let recipes: [Recipe]
    enum CodingKeys: String, CodingKey {
        case recipes = "meals"
    }
}
