//
//  RecipesUITests.swift
//  RecipesUITests
//
//  Created by Romaric Allahramadji on 2/21/25.
//

import XCTest

final class RecipesViewUITests: XCTestCase {
    let app = XCUIApplication()
    override func setUp() {
        continueAfterFailure = false
        app.launchEnvironment["UI_TEST_SCENARIO"] = "loading"
        app.launch()
    }
    override func tearDownWithError() throws {
        app.terminate()
    }
    func testScrollViewAppears() {
        let recipesviewScrollView = app.scrollViews["recipesView"]
        XCTAssertTrue(recipesviewScrollView.exists, "ScrollView should have appeared")
    }
    func testNavigationToDetailsPage() {
        let elementsQuery = app.scrollViews["recipesView"].otherElements
        let button = app.buttons["recipeRow_53049"]
        // Assert that the button exists
        XCTAssertTrue(button.exists, "The 'Apam Balik' button should exist.")
        // Tap the button
        button.tap()
        // Check if navigation to the detail page occurred
        let detailNavBar = app.navigationBars["_TtGC7SwiftUI19UIHosting"]
        XCTAssertTrue(detailNavBar.exists, "The navigation bar for the details page should be visible.")
        // Navigate back to the 'Desserts' page
        detailNavBar.buttons["Desserts"].tap()
        // Assert that we returned to the main view
        XCTAssertTrue(elementsQuery.staticTexts["Apam Balik"].exists, "The app should return to the 'Desserts' page.")
    }
    func testAppLaunchesSuccessfully() throws {
        let navigationBar = app.navigationBars["Desserts"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5), "The app should launch and show the 'Desserts' navigation bar.")
    }
    func testRecipeRowExists() throws {
        let recipeRow = app.buttons.matching(identifier: "recipeRow_53049").firstMatch
        XCTAssertTrue(recipeRow.exists, "At least one recipe row should be visible.")
    }
}

// class RecipesViewUITests: XCTestCase {
//    var app: XCUIApplication!
//
//    override func setUpWithError() throws {
//        continueAfterFailure = false
//        app = XCUIApplication()
//    }
//    override func tearDownWithError() throws {
//        app = nil
//    }
//    func printAppHierarchy() {
//        let hierarchy = app.debugDescription
//        print(hierarchy)
//    }
//    // Test Loading State
//    func testRecipesViewLoadingState() throws {
//        app.launchArguments.append("-mockSlowLoading")
//        app.launch()
//        // Find the ProgressView as an ActivityIndicator.
//        let loadingIndicator = app.activityIndicators["loadingIndicator"]
//        print(printAppHierarchy())
//        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 10.0),
//                      "Loading indicator should appear while fetching recipes")
//    }
//    // Test Success State
//    func testRecipesViewSuccessState() throws {
//        app.launchArguments.append("-mockRecipes")
//        app.launch()
//        let scrollView = app.scrollViews["recipesScrollView"]
//        XCTAssertTrue(scrollView.waitForExistence(timeout: 5.0),
//                      "Scroll view should appear with recipes")
//        let recipeName = app.staticTexts["recipeName_12345"]
//        XCTAssertTrue(recipeName.exists, "Recipe name should be visible")
//        XCTAssertEqual(recipeName.label, "Chocolate Cake", "Recipe name should match expected value")
//
//        let thumbnailImage = app.images["thumbnailImage_12345"]
//        XCTAssertTrue(thumbnailImage.exists, "Thumbnail image should be visible")
//
//        let chevron = app.images["chevron_12345"]
//        XCTAssertTrue(chevron.exists, "Chevron should be visible")
//    }
//    // Test Navigation to Details
//    func testRecipesViewNavigationToDetails() throws {
//        app.launchArguments.append("-mockRecipes")
//        app.launch()
//
//        let recipeRow = app.otherElements["recipeRow_12345"]
//        XCTAssertTrue(recipeRow.waitForExistence(timeout: 5.0),
//                      "Recipe row should exist")
//        recipeRow.tap()
//
//        let recipeDetailsView = app.otherElements["recipeDetailsView"]
//        XCTAssertTrue(recipeDetailsView.waitForExistence(timeout: 5.0),
//                      "Should navigate to RecipeDetailsView")
//    }
//    // Test Empty State
//    func testRecipesViewEmptyState() throws {
//        app.launchArguments.append("-mockEmptyRecipes")
//        app.launch()
//        let noRecipesLabel = app.staticTexts["noRecipesLabel"]
//        XCTAssertTrue(noRecipesLabel.waitForExistence(timeout: 5.0),
//                      "No recipes label should appear for empty state")
//    }
//    // Test Error State
//    func testRecipesViewErrorState() throws {
//        app.launchArguments.append("-mockError")
//        app.launch()
//
//        let alert = app.alerts["Error"]
//        XCTAssertTrue(alert.waitForExistence(timeout: 5.0),
//                      "Error alert should appear")
//
//        let alertMessage = alert.staticTexts.element(boundBy: 0)
//        XCTAssertEqual(alertMessage.label,
//                       "Network error: The Internet connection appears to be offline.",
//                       "Alert should show network error")
//
//        alert.buttons["OK"].tap()
//    }
// }
