import SwiftUI

struct FavoritesView: View {
    @ObservedObject var recipeData: RecipeData
    @Binding var selectedTab: Int
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            let favoriteRecipes = recipeData.recipes.values.flatMap({ $0 }).filter({ $0.favorites })
            
            if favoriteRecipes.isEmpty {
                VStack {
                    Spacer()
                    Text("Избранных пока нет")
                        .font(.custom("AvenirNext-Medium", size: 20))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(favoriteRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeData: recipeData)) {
                                RecipeCard(recipe: recipe, recipeData: recipeData)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Избранные")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    selectedTab = 0
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
}

struct FavoritesListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesListView(recipeData: RecipeData(), selectedTab: .constant(2))
    }
}
