import UIKit
import SwiftUI

// Класс для загрузки рецептов
class RecipeData: ObservableObject {
    @Published var recipes: [String: [Recipe]] = [:]
    @Published var popularRecipes: [Recipe] = [] // Новое свойство для хранения популярных рецептов
    let categories = ["Завтрак", "Напитки", "Горячие блюда", "Салаты", "Выпечка"]
    
    init() {
        loadRecipes()
        generatePopularRecipes() // Генерируем популярные рецепты при инициализации
    }
    
    private func loadRecipes() {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            var allRecipes = try JSONDecoder().decode([Recipe].self, from: data)
            
            // Загружаем состояние избранных рецептов из UserDefaults
            if let favoritesData = UserDefaults.standard.data(forKey: "favorites"),
               let favoritesDict = try? JSONDecoder().decode([Int: Bool].self, from: favoritesData) {
                for i in 0..<allRecipes.count {
                    if let isFavorite = favoritesDict[allRecipes[i].id] {
                        allRecipes[i].favorites = isFavorite
                    }
                }
            }
            
            // Группируем рецепты по категориям
            for category in categories {
                recipes[category] = allRecipes.filter { $0.category == category }
            }
        } catch {
            print("Error loading JSON: \(error)")
        }
    }
    
    // Метод для сохранения состояния избранных рецептов
    func saveFavorites() {
        var favoritesDict: [Int: Bool] = [:]
        for categoryRecipes in recipes.values {
            for recipe in categoryRecipes {
                favoritesDict[recipe.id] = recipe.favorites
            }
        }
        if let data = try? JSONEncoder().encode(favoritesDict) {
            UserDefaults.standard.set(data, forKey: "favorites")
        }
    }
    
    // Метод для генерации фиксированного набора популярных рецептов
    private func generatePopularRecipes() {
        var selectedRecipes: [Recipe] = []
        var usedRecipeIDs: Set<Int> = [] // Для отслеживания уже выбранных рецептов
        
        // Первый цикл: по одному рецепту из каждой категории
        for category in categories {
            if let categoryRecipes = recipes[category]?.shuffled() {
                if let recipe = categoryRecipes.first(where: { !usedRecipeIDs.contains($0.id) }) {
                    selectedRecipes.append(recipe)
                    usedRecipeIDs.insert(recipe.id)
                }
            }
        }
        
        // Второй цикл: ещё по одному рецепту из каждой категории, исключая уже выбранные
        for category in categories {
            if let categoryRecipes = recipes[category]?.shuffled() {
                if let recipe = categoryRecipes.first(where: { !usedRecipeIDs.contains($0.id) }) {
                    selectedRecipes.append(recipe)
                    usedRecipeIDs.insert(recipe.id)
                }
            }
        }
        
        popularRecipes = selectedRecipes
    }
    
    // Метод для получения фиксированного набора популярных рецептов
    func getRandomRecipes() -> [Recipe] {
        return popularRecipes // Возвращаем фиксированный набор
    }
    
    // Метод для получения рецепта дня
    func getRecipeOfTheDay() -> Recipe? {
        let allRecipes = recipes.values.flatMap { $0 }
        guard !allRecipes.isEmpty else { return nil }
        
        // Используем текущий день как seed для выбора рецепта
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % allRecipes.count
        return allRecipes[index]
    }
}
