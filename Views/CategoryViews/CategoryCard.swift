import SwiftUI

// Компонент для карточки категории
struct CategoryCard: View {
    let category: String
    @ObservedObject var recipeData: RecipeData
    
    var body: some View {
        ZStack {
            if let firstRecipe = recipeData.recipes[category]?.first {
                VStack {
                    Image(firstRecipe.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 100)
                        .cornerRadius(15)
                        .clipped()
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    
                    Text(category)
                        .font(.custom("AvenirNext-Medium", size: 16))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.top, 5)
                }
                .frame(width: 150)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 3)
            }
        }
    }
}
