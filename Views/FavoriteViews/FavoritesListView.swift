import SwiftUI

// Экран для вкладки "Избранное"
struct FavoritesListView: View {
    @ObservedObject var recipeData: RecipeData
    @Binding var selectedTab: Int // Для сброса вкладки при возвращении
    @Environment(\.presentationMode) private var presentationMode // Для управления навигацией
    
    var body: some View {
        ZStack {
            // Бежевый градиентный фон, как в MainView и SearchView
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Проверяем, есть ли избранные рецепты
            let favoriteRecipes = recipeData.recipes.values.flatMap({ $0 }).filter({ $0.favorites })
            
            if favoriteRecipes.isEmpty {
                // Если избранных нет, показываем сообщение
                VStack {
                    Spacer()
                    Text("Избранных пока нет")
                        .font(.custom("AvenirNext-Medium", size: 20))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                // Если есть избранные, показываем их в сетке
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
        .navigationBarBackButtonHidden(true) // Скрываем стандартную кнопку "Back"
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    selectedTab = 0 // Сбрасываем вкладку на "Домик"
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
