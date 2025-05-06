//
//  RecipesTests.swift
//  RecipesTests
//
//  Created by Romaric Allahramadji on 8/6/24.
//

import XCTest
@testable import Recipes

final class RecipeViewModelTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var recipesViewModel: RecipesViewModel!
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        recipesViewModel = RecipesViewModel(networkService: mockNetworkService)
   
    }
    override func tearDown() {
        recipesViewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    // MARK: - Fetching Recipes Tests
    func test_a_recipe_is_fetched() async {
        // Given
        do {
            mockNetworkService.mockResponse = try JSONEncoder().encode(mockValidRecipes())
        } catch {
            XCTFail("Encoding failed with error: \(error)")
            return
        }
        // When
        await recipesViewModel.fetchRecipes()
        let recipes = recipesViewModel.recipes
        // Then
        XCTAssertEqual(recipes.count, 2)
    }
    func test_fetchRecipes_whenNoValidRecipesExist_throwsValidationError() async {
        // Given
        do {
            mockNetworkService.mockResponse = try JSONEncoder().encode(RecipesResponse(recipes:
                [Recipe(id: "", name: "", thumbnailURL: ""), Recipe(id: "", name: "", thumbnailURL: "")]))
        } catch {
            XCTFail("Encoding failed with error: \(error)")
            return
        }
        // When
        await recipesViewModel.fetchRecipes()
        let result = recipesViewModel.recipes.filter { $0.isValid }
        // Then
        XCTAssertEqual(result.count, 0)
        XCTAssertEqual(recipesViewModel.errorMessage, RecipeError.noValidRecipes.errorDescription)
    }
    func test_fetchRecipes_whenNetworkFails_throwsNetworkError() async {
        // Given
        let urlError = URLError(.notConnectedToInternet)
        let viewModel = RecipesViewModel(networkService: FailingNetworkService(errorType: .networkError(urlError)))
        // When
        await viewModel.fetchRecipes()
        // Then
        XCTAssertEqual(viewModel.errorMessage, RecipeError.networkError(urlError).errorDescription)
    }
    func test_fetchRecipes_whenUnknownErrorOccurs_throwsUnknownError() async {
        // Given
        let unknownError = NSError(domain: "TestDomain", code: -1, userInfo: nil)
        let viewModel = RecipesViewModel(networkService: FailingNetworkService(errorType: .unknown(unknownError)))
        // When
        await viewModel.fetchRecipes()
        // Then
        XCTAssertEqual(viewModel.errorMessage, RecipeError.unknown(unknownError).errorDescription)
    }
    // MARK: - Error Handling Tests
    func test_handleFetchError_withURLError_returnsNetworkErrorMessage() async {
        // Given
        let urlError = URLError(.notConnectedToInternet)
        let viewModel = RecipesViewModel(networkService: FailingNetworkService(errorType: .networkError(urlError)))
        // When
        await viewModel.fetchRecipes()
        // Then
        XCTAssertEqual(viewModel.errorMessage, RecipeError.networkError(urlError).errorDescription)
    }
    func test_handleFetchError_withValidationError_returnsValidationErrorMessage() async {
        // Given
        let viewModel = RecipesViewModel(networkService: FailingNetworkService(errorType: .noValidRecipes))
        // When
        await viewModel.fetchRecipes()
        // Then
        XCTAssertEqual(viewModel.errorMessage, RecipeError.noValidRecipes.errorDescription)
    }
    func test_handleFetchError_withUnknownError_returnsUnknownErrorMessage() async {
        // Given
        let unknownError = NSError(domain: "TestDomain", code: -1, userInfo: nil)
        let viewModel = RecipesViewModel(networkService: FailingNetworkService(errorType: .unknown(unknownError)))
        // When
        await viewModel.fetchRecipes()
        // Then
        XCTAssertEqual(viewModel.errorMessage, RecipeError.unknown(unknownError).errorDescription)
    }
    func test_fetchRecipes_withViewModelDeallocatedError_setsCorrectErrorMessage() async {
        // Given
        let viewModel = RecipesViewModel(networkService: FailingNetworkService(errorType: .viewModelDeallocated))
        // When
        await viewModel.fetchRecipes()
        // Then
        XCTAssertEqual(viewModel.errorMessage, RecipeError.viewModelDeallocated.errorDescription)
    }
    func test_fetchRecipes_withViewModelrecipeNotFound_setsCorrectErrorMessage() async {
        // Given
        let viewModel = RecipesViewModel(networkService: FailingNetworkService(errorType: .recipeNotFound))
        // When
        await viewModel.fetchRecipes()
        // Then
        XCTAssertEqual(viewModel.errorMessage, RecipeError.recipeNotFound.errorDescription)
    }
    // MARK: - Recipe Validation Test
    func test_recipe_is_valid() async {
        // Given
        var recipe = [Recipe]()
        do {
            mockNetworkService.mockResponse = try JSONEncoder().encode(mockValidRecipes())
        } catch {
            XCTFail("Encoding failed with error: \(error)")
            return
        }
        // When
        await recipesViewModel.fetchRecipes()
        recipe = recipesViewModel.recipes.filter { $0.isValid }
        // Then
        XCTAssertTrue(!recipe.isEmpty)
    }
    private func mockValidRecipes() -> RecipesResponse {
        return RecipesResponse(recipes:
            [
            Recipe(id: "1", name: "Pasta", thumbnailURL: "https://example.com/pasta.jpg"),
            Recipe(id: "2", name: "Pizza", thumbnailURL: "https://example.com/pizza.jpg")
        ])
    }
}
// MARK: - Mock Failing Network Service
class FailingNetworkService: NetworkServiceProtocol {
    func fetchData<T>(endPoint: String) async throws -> T where T : Decodable {
        throw errorType
    }
    let errorType: RecipeError
    init(errorType: RecipeError) {
        self.errorType = errorType
    }
}
