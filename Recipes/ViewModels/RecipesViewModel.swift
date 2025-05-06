//
//  RecipesViewModel.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/6/24.
//

import Foundation
import CoreData

class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: String = "Dessert"
    private var networkService: NetworkServiceProtocol
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    fileprivate func fetchFromCachedData() {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<CachedRecipe> = CachedRecipe.fetchRequest()
        do {
            let cachedRecipes = try context.fetch(fetchRequest)
            if !cachedRecipes.isEmpty {
                let mappedRecipes = cachedRecipes.map {
                    Recipe(id: $0.id ?? "", name: $0.name ?? "", thumbnailURL: $0.thumbnailURL ?? "")
                }.sorted { $0.name < $1.name }
                let allRecipesValid = mappedRecipes.filter { $0.isValid }
                if !allRecipesValid.isEmpty {
                    self.recipes = mappedRecipes
                    print("Retrieved from Core Data")
                    return
                }
            }
        } catch {
            print("❌ Error fetching cached recipes: \(error.localizedDescription)")
        }
    }
    @MainActor
    func fetchRecipes() async {
        self.isLoading = true
        defer { self.isLoading = false }
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            fetchFromCachedData()
        }
        do {
            let data: RecipesResponse = try await networkService.fetchData(
                endPoint: RecipeEndpoint.recipesList(category: selectedCategory).urlString
            )
            let validRecipes = data.recipes.filter { $0.isValid }
            if validRecipes.isEmpty {
                throw RecipeError.noValidRecipes
            }
            self.recipes = validRecipes.sorted { $0.name < $1.name }
            CoreDataManager.shared.cacheRecipes(self.recipes)
        } catch {
            handle(error.asRecipeError)
        }
    }
    private func handle(_ error: RecipeError) {
        errorMessage = error.errorDescription
    }
}
