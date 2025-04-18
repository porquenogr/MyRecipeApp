//
//  RandomRecipesListView.swift
//  Healthy Recipes
//
//  Created by Гузаль on 18.04.2025.
//

import SwiftUI

// Экран списка 10 случайных рецептов (по 2 из каждой категории)
struct RandomRecipesListView: View {
    @ObservedObject var recipeData: RecipeData
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(recipeData.popularRecipes) { recipe in // Используем popularRecipes
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeData: recipeData)) {
                        RecipeCard(recipe: recipe, recipeData: recipeData)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Популярные рецепты")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
