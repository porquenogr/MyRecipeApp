import SwiftUI

// Компонент для секции "Featured" (Рецепт дня)
struct FeaturedSection: View {
    @ObservedObject var recipeData: RecipeData
    
    var body: some View {
        if let recipeOfTheDay = recipeData.getRecipeOfTheDay() {
            NavigationLink(destination: RecipeDetailView(recipe: recipeOfTheDay, recipeData: recipeData)) {
                ZStack {
                    Color.blue.opacity(0.2)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    
                    Image(recipeOfTheDay.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .cornerRadius(15)
                        .clipped()
                    
                    VStack {
                        Spacer()
                        Text("Рецепт дня: \(recipeOfTheDay.name)")
                            .font(.custom("AvenirNext-Bold", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                    }
                }
                .frame(height: 150)
            }
        }
    }
}
