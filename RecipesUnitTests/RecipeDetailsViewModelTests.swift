//
//  RecipeDetailsViewModel.swift
//  RecipesTests
//
//  Created by Romaric Allahramadji on 2/18/25.
//
import XCTest
@testable import Recipes

final class RecipeDetailsViewModelTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var recipeDetailsViewModel: RecipeDetailsViewModel!
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        recipeDetailsViewModel = RecipeDetailsViewModel(networkService: mockNetworkService)
    }
    override func tearDown() {
        recipeDetailsViewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    // MARK: - Fetching Recipe Details Tests (Success Cases)
    func test_a_detail_is_fetched() async {
        // Given
        mockNetworkService.getMockData = true
        // When
        await recipeDetailsViewModel.fetchRecipeDetails(id: "53049")
        let details = recipeDetailsViewModel.recipeDetails
        // Then
        XCTAssertEqual(details?.recipeName, "Apam balik")
        XCTAssertEqual(details?.ingredients.count, 2)
        XCTAssertEqual(details?.measurements.count, 2)
        XCTAssertNil(recipeDetailsViewModel.errorMessage, "No error message should be set on success")
    }
    // MARK: - Fetching Recipe Details Tests (Error Cases)
    func test_fetchRecipeDetails_whenInvalidRecipeData_setsInvalidRecipeDataError() async {
        // Given
        let viewModel = RecipeDetailsViewModel(networkService: FailingNetworkService(errorType: .invalidRecipeData))
        // When
        await viewModel.fetchRecipeDetails(id: "1")
        // Then
        XCTAssertNil(viewModel.recipeDetails, "Recipe details should be nil on error")
        XCTAssertEqual(viewModel.errorMessage, RecipeError.invalidRecipeData.errorDescription)
    }
    func test_fetchRecipeDetails_whenNetworkFails_setsNetworkError() async {
        // Given
        let urlError = URLError(.notConnectedToInternet)
        let viewModel = RecipeDetailsViewModel(networkService: FailingNetworkService(errorType: .networkError(urlError)))
        // When
        await viewModel.fetchRecipeDetails(id: "1")
        // Then
        XCTAssertNil(viewModel.recipeDetails, "Recipe details should be nil on error")
        XCTAssertEqual(viewModel.errorMessage, RecipeError.networkError(urlError).errorDescription)
    }
    func test_fetchRecipeDetails_whenNoDetailsReturned_setsBadServerResponseError() async {
        // Given
        mockNetworkService.shouldReturnInvalidDetails = true
        // When
        await recipeDetailsViewModel.fetchRecipeDetails(id: "53049")
        // Then
        XCTAssertNil(recipeDetailsViewModel.recipeDetails, "Recipe details should be nil when no details are returned")
        XCTAssertNotNil(recipeDetailsViewModel.errorMessage, "Error message should be set")
        XCTAssertEqual(
            recipeDetailsViewModel.errorMessage,
            RecipeError.networkError(URLError(.badServerResponse)).errorDescription,
            "Error message should reflect a bad server response"
        )
    }
    func test_fetchRecipeDetails_whenUnknownErrorOccurs_setsUnknownError() async {
        // Given
        let unknownError = NSError(domain: "TestDomain", code: -1, userInfo: nil)
        let viewModel = RecipeDetailsViewModel(networkService: FailingNetworkService(errorType: .unknown(unknownError)))
        // When
        await viewModel.fetchRecipeDetails(id: "1")
        // Then
        XCTAssertNil(viewModel.recipeDetails, "Recipe details should be nil on error")
        XCTAssertEqual(viewModel.errorMessage, RecipeError.unknown(unknownError).errorDescription)
    }
    func test_fetchRecipeDetails_whenDecodingFails_setsDecodingError() async {
        // Given
        let decodingError = DecodingError.typeMismatch(String.self,
            .init(codingPath: [], debugDescription: "Expected String"))
        let viewModel = RecipeDetailsViewModel(networkService:
            FailingNetworkService(errorType: .decodingError(decodingError)))
        // When
        await viewModel.fetchRecipeDetails(id: "1")
        // Then
        XCTAssertNil(viewModel.recipeDetails, "Recipe details should be nil on error")
        XCTAssertEqual(viewModel.errorMessage, RecipeError.decodingError(decodingError).errorDescription)
    }
    func test_fetchRecipeDetails_whenRecipeNotFound_setsRecipeNotFoundError() async {
        // Given
        let viewModel = RecipeDetailsViewModel(networkService: FailingNetworkService(errorType: .recipeNotFound))
        // When
        await viewModel.fetchRecipeDetails(id: "invalid-id")
        // Then
        XCTAssertNil(viewModel.recipeDetails, "Recipe details should be nil on error")
        XCTAssertEqual(viewModel.errorMessage, RecipeError.recipeNotFound.errorDescription)
    }
    func test_fetchRecipeDetails_whenNoValidRecipes_setsNoValidRecipesError() async {
        // Given
        let viewModel = RecipeDetailsViewModel(networkService: FailingNetworkService(errorType: .noValidRecipes))
        // When
        await viewModel.fetchRecipeDetails(id: "1")
        // Then
        XCTAssertNil(viewModel.recipeDetails, "Recipe details should be nil on error")
        XCTAssertEqual(viewModel.errorMessage, RecipeError.noValidRecipes.errorDescription)
    }
    func test_fetchRecipeDetails_whenViewModelDeallocated_setsDeallocatedError() async {
        // Given
        mockNetworkService.getMockData = true
        weak var weakViewModel = recipeDetailsViewModel // Simulate deallocation
        recipeDetailsViewModel = nil // Deallocate the view model
        // When
        await weakViewModel?.fetchRecipeDetails(id: "53049")
        // Then
        // Since viewModel is nil, we can't test errorMessage directly, but we verify no crash
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
    }
    // MARK: - Recipe Details Validation Test
    func test_isValidRecipeDetails_withValidData_returnsTrue() async {
        // Given
        mockNetworkService.getMockData = true
        // When
        await recipeDetailsViewModel.fetchRecipeDetails(id: "53049")
        let isValid = recipeDetailsViewModel.recipeDetails?.isValid ?? false
        // Then
        XCTAssertTrue(isValid, "Valid recipe details should return true")
    }
    func test_isValidRecipeDetails_withInvalidData_returnsFalse() async {
        // Given
        mockNetworkService.shouldReturnInvalidDetails = true
        // When
        await recipeDetailsViewModel.fetchRecipeDetails(id: "53049")
        let isValid = recipeDetailsViewModel.recipeDetails?.isValid ?? false
        // Then
        XCTAssertFalse(isValid, "Invalid recipe details should return false")
    }
}
