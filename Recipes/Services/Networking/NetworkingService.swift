//
//  NetworkingService.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/6/24.
//

import Foundation

class NetworkingService: NetworkServiceProtocol {
    static let shared = NetworkingService()
    private let session: URLSession
    init(session: URLSession = .shared) {
          // Ensure URLSession uses default configuration with caching
          let config = URLSessionConfiguration.default
          config.requestCachePolicy = .useProtocolCachePolicy // Explicitly set to respect server cache headers
          self.session = URLSession(configuration: config)
      }
    func fetchData<T>(endPoint: String) async throws -> T where T : Decodable {
        guard let url = URL(string: endPoint) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let jsonResult = try JSONDecoder().decode(T.self, from: data)
        return jsonResult
    }
}
