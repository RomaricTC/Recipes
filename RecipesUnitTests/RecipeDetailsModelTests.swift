//
//  RecipeDetailsModelTests.swift
//  RecipesTests
//
//  Created by Romaric Allahramadji on 2/20/25.
//

import XCTest
@testable import Recipes

final class RecipeDetailsModelTests: XCTestCase {
    class URLErrorMockService: NetworkServiceProtocol {
        func fetchData<T>(endPoint: String) async throws -> T where T: Decodable {
            throw URLError(.notConnectedToInternet)
        }
    }
    class DecodingErrorMockService: NetworkServiceProtocol {
        func fetchData<T>(endPoint: String) async throws -> T where T: Decodable {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: "Expected String"))
        }
    }
    class GenericErrorMockService: NetworkServiceProtocol {
        func fetchData<T>(endPoint: String) async throws -> T where T: Decodable {
            throw NSError(domain: "TestDomain", code: -1, userInfo: nil)
        }
    }
    func test_init_decoder_withValidData_succeeds() throws {
        // Given
        let json = """
        {
            "strMeal": "Spaghetti",
            "strInstructions": "Cook the pasta",
            "strMealThumb": "https://example.com/spaghetti.jpg",
            "idMeal": "12345",
            "strIngredient1": "Pasta",
            "strIngredient2": "Tomato Sauce",
            "strIngredient3": "",
            "strMeasure1": "500g",
            "strMeasure2": "2 cups",
            "strMeasure3": ""
        }
        """.data(using: .utf8)!
        // When
        let recipe = try JSONDecoder().decode(RecipeDetailsModel.self, from: json)
        // Then
        XCTAssertEqual(recipe.recipeName, "Spaghetti")
        XCTAssertEqual(recipe.instructions, "Cook the pasta")
        XCTAssertEqual(recipe.recipeThumbnailURL, "https://example.com/spaghetti.jpg")
        XCTAssertEqual(recipe.recipeID, "12345")
        XCTAssertEqual(recipe.ingredients, ["Pasta", "Tomato Sauce"])
        XCTAssertEqual(recipe.measurements, ["500g", "2 cups"])
    }
    func testIdPropertyReturnsRecipeID() {
        // Arrange
        let testRecipeID = "12345"
        let recipe = RecipeDetailsModel(
            recipeName: "Test Recipe",
            instructions: "Test Instructions",
            recipeThumbnailURL: "https://example.com/thumb.jpg",
            recipeID: testRecipeID,
            ingredients: ["Ingredient 1"],
            measurements: ["1 cup"]
        )
        // Act
        let result = recipe.id
        // Assert
        XCTAssertEqual(result, testRecipeID, "The id property should match the recipeID")
        XCTAssertEqual(recipe.id, recipe.recipeID, "The id property should equal recipeID")
    }
    func test_init_decoder_withNoIngredients_returnsEmptyArrays() throws {
        // Given
        let json = """
        {
            "strMeal": "Spaghetti",
            "strInstructions": "Cook the pasta",
            "strMealThumb": "https://example.com/spaghetti.jpg",
            "idMeal": "12345",
            "strIngredient1": "",
            "strMeasure1": ""
        }
        """.data(using: .utf8)!
        // When
        let recipe = try JSONDecoder().decode(RecipeDetailsModel.self, from: json)
        // Then
        XCTAssertTrue(recipe.ingredients.isEmpty)
        XCTAssertTrue(recipe.measurements.isEmpty)
    }
    func test_init_decoder_withMissingRequiredFields_throws() {
        // Given
        let json = """
        {
            "strMeal": "Spaghetti",
            "strInstructions": "Cook the pasta",
            "idMeal": "12345"
        }
        """.data(using: .utf8)!
        // Then
        XCTAssertThrowsError(try JSONDecoder().decode(RecipeDetailsModel.self, from: json)) { error in
            guard case .keyNotFound = error as? DecodingError else {
                XCTFail("Expected .keyNotFound error but got \(error)")
                return
            }
        }
    }
    func test_init_decoder_withNonStringValues_throws() {
        // Given
        let json = """
        {
            "strMeal": "Spaghetti",
            "strInstructions": "Cook the pasta",
            "strMealThumb": "https://example.com/spaghetti.jpg",
            "idMeal": 12345,
            "strIngredient1": "Pasta",
            "strMeasure1": "500g"
        }
        """.data(using: .utf8)!
        // Then
        XCTAssertThrowsError(try JSONDecoder().decode(RecipeDetailsModel.self, from: json)) { error in
            guard case .typeMismatch = error as? DecodingError else {
                XCTFail("Expected .typeMismatch error but got \(error)")
                return
            }
        }
    }
    func test_init_decoder_withMultipleIngredients_handlesAllIngredients() throws {
        // Given
        let json = """
        {
            "strMeal": "Complex Dish",
            "strInstructions": "Cook everything",
            "strMealThumb": "https://example.com/dish.jpg",
            "idMeal": "12345",
            "strIngredient1": "First",
            "strIngredient2": "Second",
            "strIngredient3": "Third",
            "strIngredient4": "",
            "strMeasure1": "1 cup",
            "strMeasure2": "2 tbsp",
            "strMeasure3": "3 oz",
            "strMeasure4": ""
        }
        """.data(using: .utf8)!
        // When
        let recipe = try JSONDecoder().decode(RecipeDetailsModel.self, from: json)
        // Then
        XCTAssertEqual(recipe.ingredients, ["First", "Second", "Third"])
        XCTAssertEqual(recipe.measurements, ["1 cup", "2 tbsp", "3 oz"])
    }
    func test_init_decoder_withMissingIngredientMeasurement_skipsIngredient() throws {
        // Given
        let json = """
        {
            "strMeal": "Simple Dish",
            "strInstructions": "Cook it",
            "strMealThumb": "https://example.com/dish.jpg",
            "idMeal": "12345",
            "strIngredient1": "First",
            "strIngredient2": "Second",
            "strMeasure1": "1 cup"
        }
        """.data(using: .utf8)!
        // When
        let recipe = try JSONDecoder().decode(RecipeDetailsModel.self, from: json)
        // Then
        XCTAssertEqual(recipe.ingredients, ["First"])
        XCTAssertEqual(recipe.measurements, ["1 cup"])
    }
    func test_fetchRecipeDetails_whenURLErrorThrown_setsNetworkErrorMessage() async {
        let urlError = URLError(.notConnectedToInternet)
        let viewModel = RecipeDetailsViewModel(networkService: URLErrorMockService())
        await viewModel.fetchRecipeDetails(id: "1")
        let expectedErrorMessage = RecipeError.networkError(urlError).errorDescription
        XCTAssertEqual(viewModel.errorMessage, expectedErrorMessage)
    }
    func test_fetchRecipeDetails_whenDecodingErrorThrown_setsDecodingErrorMessage() async {
        let decodingError = DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: "Expected String"))
        let viewModel = RecipeDetailsViewModel(networkService: DecodingErrorMockService())
        await viewModel.fetchRecipeDetails(id: "1")
        let expectedErrorMessage = RecipeError.decodingError(decodingError).errorDescription
        XCTAssertEqual(viewModel.errorMessage, expectedErrorMessage)
    }
    func test_fetchRecipeDetails_whenGenericErrorThrown_setsUnknownErrorMessage() async {
        let genericError = NSError(domain: "TestDomain", code: -1, userInfo: nil)
        let viewModel = RecipeDetailsViewModel(networkService: GenericErrorMockService())
        await viewModel.fetchRecipeDetails(id: "1")
        let expectedErrorMessage = RecipeError.unknown(genericError).errorDescription
        XCTAssertEqual(viewModel.errorMessage, expectedErrorMessage)
    }
}
