//
//  RecipesUITestsLaunchTests.swift
//  RecipesUITests
//
//  Created by Romaric Allahramadji on 2/21/25.
//

import XCTest

final class RecipesUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
