//
//  ErrorType.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/12/24.
//

import Foundation

enum RecipeError: LocalizedError {
    case viewModelDeallocated
    case recipeNotFound
    case invalidRecipeData
    case noValidRecipes
    case networkError(URLError)
    case decodingError(DecodingError)
    case unknown(Error)
    var errorDescription: String? {
        switch self {
        case .viewModelDeallocated:
            return "An unexpected error occurred. Please try again."
        case .recipeNotFound:
            return "Recipe not found."
        case .invalidRecipeData:
            return "Invalid recipe data received."
        case .noValidRecipes:
            return "No valid recipes found for this category."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to process data: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

extension Error {
    var asRecipeError: RecipeError {
        switch self {
        case let urlError as URLError:
            return .networkError(urlError)
        case let decodingError as DecodingError:
            return .decodingError(decodingError)
        case let recipeError as RecipeError:
            return recipeError
        default:
            return .unknown(self)
        }
    }
}
