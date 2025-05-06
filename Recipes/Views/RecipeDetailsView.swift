//
//  RecipeDetailView.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/6/24.
//

import SwiftUI
import Kingfisher

struct RecipeDetailsView: View {
    let recipeID: String
    let recipeThumbnailURL: String
    @StateObject var viewModel = RecipeDetailsViewModel(networkService: NetworkingService.shared)
    @State private var imageVisible = false
    @State private var showAlert = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView("Loading Recipe Details...")
                        .accessibilityIdentifier("loadingIndicator")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let recipe = viewModel.recipeDetails {
                    Text(recipe.recipeName.titleCased())
                        .bold()
                        .font(.title)
                        .padding(.top, -30)
                        .accessibilityIdentifier("recipeNameLabel")
                    KFImage(URL(string: recipe.recipeThumbnailURL))
                        .placeholder {
                            ZStack {
                                Color.gray.opacity(0.2)
                                ProgressView()
                            }
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .frame(width: 320)
                        .shadow(radius: 3)
                    Text("Instructions:")
                        .bold()
                        .font(.title2)
                        .padding(.vertical)
                        .accessibilityIdentifier("instructionsHeader")
                    Text(recipe.instructions)
                        .accessibilityIdentifier("instructionsText")
                    Text("Ingredients/Measurements:")
                        .bold()
                        .font(.title2)
                        .padding(.vertical)
                        .accessibilityIdentifier("ingredientsHeader")
                    VStack(alignment: .leading, spacing: 10) {
                        let ingredientPairs = Array(zip(recipe.ingredients, recipe.measurements))
                        let uniquePairs = ingredientPairs.enumerated().map { index, pair in
                            return (id: "\(index)-\(pair.0)-\(pair.1)", pair: pair)
                        }
                        ForEach(uniquePairs, id: \.id) { item in
                            HStack {
                                Text(standardizeIngredientName(item.pair.0))
                                    .accessibilityIdentifier("ingredient_\(item.id)")
                                Text(item.pair.1)
                                    .accessibilityIdentifier("measurement_\(item.id)")
                            }
                        }
                    }
                } else {
                    Text("No details available.")
                        .accessibilityIdentifier("noDetailsLabel")
                }
            }
            .padding()
            .scaleEffect(imageVisible ? 1.0 : 0.8)
            .animation(.easeInOut(duration: 0.5), value: imageVisible)
            .onAppear {
                imageVisible = true
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .accessibilityIdentifier("recipeDetailsView")
            .task {
                await viewModel.fetchRecipeDetails(id: recipeID)
                if viewModel.errorMessage != nil {
                    showAlert = true
                }
            }
        }
    }
    func standardizeIngredientName(_ ingredient: String) -> String {
        return ingredient.capitalized
    }
}

#Preview {
    RecipeDetailsView(recipeID: "52893", recipeThumbnailURL: "")
}
