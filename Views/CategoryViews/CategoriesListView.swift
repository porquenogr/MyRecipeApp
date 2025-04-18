import SwiftUI

// Экран списка всех категорий (в виде иконок)
struct CategoriesListView: View {
    let categories: [String]
    @ObservedObject var recipeData: RecipeData
    
    init(categories: [String], recipeData: RecipeData) {
        self.categories = categories
        self.recipeData = recipeData
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    NavigationLink(destination: CategoryRecipesView(category: category, recipes: recipeData.recipes[category] ?? [], recipeData: recipeData)) {
                        CategoryCard(category: category, recipeData: recipeData)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Все категории")
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
