//
//  RecipeEndpoint.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 2/13/25.
//

import Foundation

enum RecipeEndpoint: Endpoint {
    case recipesList(category: String)
    case recipeDetails(id: String)
    var urlString: String {
        switch self {
        case .recipesList(let category):
            return "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(category)"
        case .recipeDetails(let id):
            return "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)"
        }
    }
}
