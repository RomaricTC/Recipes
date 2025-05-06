//
//  Extensions.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/9/24.
//

import Foundation
import UIKit

extension Recipe {
    var isValid: Bool {
        return !id.isEmpty && !name.isEmpty && !thumbnailURL.isEmpty
    }
}
extension RecipeDetailsModel {
    var isValid: Bool {
    return !recipeID.isEmpty && !recipeName.isEmpty && !instructions.isEmpty && !ingredients.isEmpty
    }
}

extension String {
    func titleCased() -> String {
        return self.capitalized
    }
}

//extension CachedRecipe {
//    var uiImage: UIImage? {
//        guard let data = self.imageData else { return nil }
//        return UIImage(data: data)
//    }
//}
