//
//  NetworkingServiceTests.swift
//  RecipesTests
//
//  Created by Romaric Allahramadji on 3/5/25.
//

import XCTest
@testable import Recipes

final class NetworkingServiceTests: XCTestCase {
    func test_fetchRecipeDetails_withValidID_returnsRecipeDetails() async throws {
        // Arrange
        let mockResponse = """
        {
            "meals": [
                {
                    "idMeal": "12345",
                    "strMeal": "Spaghetti",
                    "strInstructions": "Cook the pasta",
                    "strMealThumb": "https://example.com/spaghetti.jpg",
                    "strIngredient1": "Pasta",
                    "strMeasure1": "500g"
                }
            ]
        }
        """.data(using: .utf8)!
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockResponse)
        }
        let session = URLSession(configuration: configuration)
        let service = MockNetworkService()
        // Act
        let recipeDetails = try await service.fetchRecipeDetails(id: "53049")
        // Assert
        XCTAssertEqual(recipeDetails.recipeID, "53049")
        XCTAssertEqual(recipeDetails.recipeName, "Apam balik")
    }
}

// Mock URLProtocol to intercept requests
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {}
}
