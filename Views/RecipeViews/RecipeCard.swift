//
//  RecipeCard.swift
//  Healthy Recipes
//
//  Created by Гузаль on 18.04.2025.
//

import SwiftUI

// Компонент для карточки рецепта с кнопкой "Избранное" в углу
struct RecipeCard: View {
    let recipe: Recipe
    @ObservedObject var recipeData: RecipeData
    @State private var isFavorite: Bool
    
    init(recipe: Recipe, recipeData: RecipeData) {
        self.recipe = recipe
        self.recipeData = recipeData
        self._isFavorite = State(initialValue: recipe.favorites)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image(recipe.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 100)
                    .cornerRadius(15)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                // Область для названия с фиксированной высотой
                Text(recipe.name)
                    .font(.custom("AvenirNext-Medium", size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 40)
                    .padding(.top, 5)
                    .padding(.horizontal, 5)
            }
            .frame(width: 150, height: 145)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 3)
            
            // Кнопка "Избранное" в правом верхнем углу
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isFavorite.toggle()
                            // Обновляем состояние в recipeData
                            if var categoryRecipes = recipeData.recipes[recipe.category] {
                                if let index = categoryRecipes.firstIndex(where: { $0.id == recipe.id }) {
                                    categoryRecipes[index].favorites = isFavorite
                                    recipeData.recipes[recipe.category] = categoryRecipes
                                    recipeData.saveFavorites()
                                }
                            }
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(isFavorite ? .red : .gray)
                            .scaleEffect(isFavorite ? 1.2 : 1.0)
                            .padding(5)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                Spacer()
            }
            .frame(width: 150, height: 100, alignment: .topTrailing)
            .padding(.top, 2)
            .padding(.trailing, 5)
        }
    }
}
