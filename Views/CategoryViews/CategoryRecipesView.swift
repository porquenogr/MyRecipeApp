import SwiftUI

// Экран списка рецептов категории
struct CategoryRecipesView: View {
    let category: String
    let recipes: [Recipe]
    @ObservedObject var recipeData: RecipeData
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(recipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeData: recipeData)) {
                        RecipeCard(recipe: recipe, recipeData: recipeData)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category)
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
