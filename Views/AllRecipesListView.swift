import SwiftUI

// Экран списка всех рецептов
struct AllRecipesListView: View {
    @ObservedObject var recipeData: RecipeData
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(recipeData.recipes.values.flatMap({ $0 })) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeData: recipeData)) {
                        RecipeCard(recipe: recipe, recipeData: recipeData)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Все рецепты")
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
