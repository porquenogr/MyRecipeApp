import SwiftUI

// Компонент для секции категорий с кликабельными кнопками и иконками
struct CategorySection: View {
    let categories: [String]
    @ObservedObject var recipeData: RecipeData
    
    // Словарь для соответствия категорий и иконок
    private let categoryIcons: [String: String] = [
        "Завтрак": "house.fill",
        "Напитки": "cup.and.saucer.fill",
        "Горячие блюда": "flame.fill",
        "Салаты": "leaf.fill",
        "Выпечка": "birthday.cake.fill"
    ]
    
    init(categories: [String], recipeData: RecipeData) {
        self.categories = categories
        self.recipeData = recipeData
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Категории")
                    .font(.custom("AvenirNext-Bold", size: 20))
                    .foregroundColor(.primary)
                
                Spacer()
                
                NavigationLink(destination: CategoriesListView(categories: categories, recipeData: recipeData)) {
                    Text("Все")
                        .font(.custom("AvenirNext-Medium", size: 16))
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(minWidth: 50)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: CategoryRecipesView(category: category, recipes: recipeData.recipes[category] ?? [], recipeData: recipeData)) {
                            HStack(spacing: 8) { // Добавляем иконку и текст в HStack
                                Image(systemName: categoryIcons[category] ?? "questionmark.circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                                
                                Text(category)
                                    .font(.custom("AvenirNext-Medium", size: 16))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16) // Увеличиваем горизонтальные отступы для баланса
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }
}
