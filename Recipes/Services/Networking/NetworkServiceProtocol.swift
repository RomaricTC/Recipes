//
//  NetworkServiceProtocol.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/7/24.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchData<T: Decodable>(endPoint: String) async throws -> T
}
