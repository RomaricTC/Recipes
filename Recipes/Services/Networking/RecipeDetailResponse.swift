//
//  RecipeDetailResponse.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 2/13/25.
//

import Foundation

struct RecipeDetailResponse: Codable {
    let details: [RecipeDetailsModel]
    enum CodingKeys: String, CodingKey {
        case details = "meals"
    }
}
