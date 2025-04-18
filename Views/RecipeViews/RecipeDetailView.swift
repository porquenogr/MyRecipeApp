//
//  RecipeDetailView.swift
//  Healthy Recipes
//
//  Created by Гузаль on 18.04.2025.
//

import SwiftUI

// Экран с деталями рецепта
struct RecipeDetailView: View {
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
            // Фоновый градиент
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Изображение рецепта с фиксированным размером
                    ZStack {
                        Image(recipe.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(15)
                            .clipped()
                            .padding(.horizontal)
                            .shadow(radius: 5)
                        
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
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(isFavorite ? .red : .gray)
                                        .scaleEffect(isFavorite ? 1.2 : 1.0)
                                        .padding(10)
                                        .background(Color.white.opacity(0.9))
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                            }
                            Spacer()
                        }
                        .frame(height: 300, alignment: .topTrailing)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                    }
                    
                    // Название рецепта (без тени)
                    Text(recipe.name)
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    // Ингредиенты (без тени)
                    Text("Ингредиенты:")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                            .font(.custom("AvenirNext-Regular", size: 16))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Шаги приготовления (без тени)
                    Text("Шаги:")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                            .font(.custom("AvenirNext-Regular", size: 16))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .ignoresSafeArea(edges: .bottom) // Добавили игнорирование нижней безопасной области
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
