//
//  ContentView.swift
//  Recipes
//
//  Created by Romaric Allahramadji on 8/6/24.
//

import SwiftUI
import Kingfisher

struct RecipesView: View {
    @StateObject var viewModel = RecipesViewModel(networkService: NetworkingService.shared)
    @State private var showAlert = false
    @State private var gridColumns = [GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Recipes...")
                        .accessibilityIdentifier("loadingIndicator")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if !viewModel.recipes.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(viewModel.recipes, id: \.id) { recipe in
                                NavigationLink(destination: RecipeDetailsView(recipeID: recipe.id, recipeThumbnailURL: recipe.thumbnailURL)) {
                                    RecipeCardView(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .accessibilityIdentifier("recipeRow_\(recipe.id)")
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .accessibilityIdentifier("recipesScrollView")
                } else {
                    ContentUnavailableView(
                        "No Recipes Found",
                        systemImage: "fork.knife",
                        description: Text("Check your connection and try again.")
                    )
                    .accessibilityIdentifier("noRecipesLabel")
                }
            }
            .navigationTitle("Desserts")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .accessibilityIdentifier("recipesView")
            .onAppear {
                Task {
                    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
                        await viewModel.fetchRecipes()
                        if viewModel.errorMessage != nil {
                            showAlert = true
                        }
                    }
                }
            }
        }
    }
}

struct RecipeCardView: View {
    let recipe: Recipe
    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage(URL(string: recipe.thumbnailURL))
                .placeholder {
                    ZStack {
                        Color.gray.opacity(0.2)
                        ProgressView()
                    }
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .accessibilityIdentifier("thumbnailImage_\(recipe.id)")
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name.titleCased())
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(.none)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .frame(height: 180)
    }
}

#Preview {
    RecipesView()
}
