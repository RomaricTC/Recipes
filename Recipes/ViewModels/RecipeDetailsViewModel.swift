//
//  RecipeDetailsViewModel.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/6/24.
//

import Foundation
import Combine
import CoreData

class RecipeDetailsViewModel: ObservableObject {
    @Published private(set) var recipeDetails: RecipeDetailsModel?
    @Published private(set) var isLoading = false
    @Published var recipeThumbnailURL: String?
    @Published private(set) var errorMessage: String?
    var recipeDetailsUrlString = "https://www.themealdb.com/api/json/v1/1/lookup.php?"
    private let networkService: NetworkServiceProtocol
    init(networkService: NetworkServiceProtocol ) {
        self.networkService = networkService
    }
    fileprivate func fetchFromCachedData( _ recipeFetchRequest: NSFetchRequest<CachedRecipe>) {
        // If CachedDetails has a relationship to CachedRecipe or a unique ID, add a predicate
        // For now, assume you fetch the first (if clearing old data ensures one entry)
        let detailsFetchRequest: NSFetchRequest<CachedDetails> = CachedDetails.fetchRequest()
        let context = CoreDataManager.shared.context
        do {
            if let cachedRecipe = try context.fetch(recipeFetchRequest).first {
                if let cachedDetails = try context.fetch(detailsFetchRequest).first {
                    var details = RecipeDetailsModel(
                        recipeName: cachedRecipe.name ?? "",
                        instructions: (cachedDetails.instructions as? String) ?? "",
                        recipeThumbnailURL: cachedRecipe.thumbnailURL ?? "",
                        recipeID: cachedRecipe.id ?? "",
                        ingredients: (cachedDetails.ingredients as? [String]) ?? [],
                        measurements: (cachedDetails.measurements as? [String]) ?? []
                    )
                    if details.isValid {
                        self.recipeDetails = details
                        return
                    }
                }
            }
        } catch {
            print("❌ Error fetching cached recipes: \(error.localizedDescription)")
        }
    }
    @MainActor
    func fetchRecipeDetails(id: String) async {
        self.isLoading = true
        defer { self.isLoading = false }
        let recipeFetchRequest: NSFetchRequest<CachedRecipe> = CachedRecipe.fetchRequest()
        recipeFetchRequest.predicate = NSPredicate(format: "id == %@", id)
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            fetchFromCachedData(recipeFetchRequest)
        }
        do {
            let data: RecipeDetailResponse = try await networkService.fetchData(endPoint: RecipeEndpoint.recipeDetails(id: id).urlString)
            guard let recipeDetails = data.details.first else {
                throw URLError(.badServerResponse)
            }
            self.recipeDetails = recipeDetails
            CoreDataManager.shared.cacheDetails(self.recipeDetails!)
        } catch {
            handle(error.asRecipeError)
            }
    }
    private func handle(_ error: RecipeError) {
        errorMessage = error.errorDescription
    }
}
