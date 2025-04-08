import SwiftUI

struct SearchView: View {
    @ObservedObject var recipeData: RecipeData
    @Binding var selectedTab: Int // Добавляем Binding для selectedTab
    @State private var searchText: String = "" // Для хранения текста поиска
    @State private var isFocused: Bool = false // Для отслеживания фокуса поля ввода
    @State private var isListVisible: Bool = false // Для анимации появления списка
    @Environment(\.presentationMode) private var presentationMode // Для управления навигацией
    
    // Фильтрованные рецепты на основе текста поиска
    private var filteredRecipes: [Recipe] {
        // Получаем все рецепты
        let allRecipes: [Recipe] = recipeData.recipes.values.joined().map { $0 }
        
        // Если текст поиска пустой, возвращаем все рецепты
        if searchText.isEmpty {
            return allRecipes
        }
        
        // Фильтруем рецепты по тексту поиска
        let filtered = allRecipes.filter { recipe in
            recipe.name.lowercased().contains(searchText.lowercased())
        }
        return filtered
    }
    
    // Функция для получения иконки категории
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Завтрак":
            return "sunrise.fill"
        case "Напитки":
            return "cup.and.saucer.fill"
        case "Горячие блюда":
            return "flame.fill"
        case "Салаты":
            return "leaf.fill"
        case "Выпечка":
            return "birthday.cake.fill"
        default:
            return "fork.knife" // Иконка по умолчанию
        }
    }
    
    var body: some View {
        ZStack {
            // Бежевый градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Поле поиска с иконкой и анимацией
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(isFocused ? .black : .gray)
                        .padding(.leading, 10)
                        .scaleEffect(isFocused ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isFocused)
                    
                    TextField("Поиск рецептов...", text: $searchText, onEditingChanged: { editing in
                        withAnimation {
                            isFocused = editing
                        }
                    })
                    .font(.custom("AvenirNext-Regular", size: 16))
                    .foregroundColor(.primary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 5)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isFocused ? Color.black.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: 1)
                            .animation(.easeInOut(duration: 0.3), value: isFocused)
                    )
                    .scaleEffect(isFocused ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: isFocused)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Список рецептов
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(filteredRecipes.indices, id: \.self) { index in
                            let recipe = filteredRecipes[index]
                            NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeData: recipeData)) {
                                HStack {
                                    // Иконка категории
                                    Image(systemName: categoryIcon(for: recipe.category))
                                        .foregroundColor(.gray)
                                        .frame(width: 20, height: 20)
                                        .padding(.leading, 10)
                                    
                                    // Название рецепта
                                    Text(recipe.name)
                                        .font(.custom("AvenirNext-Medium", size: 16))
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 5)
                                    
                                    Spacer()
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.95), Color(red: 0.98, green: 0.96, blue: 0.90)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .shadow(radius: 2)
                                .offset(y: isListVisible ? 0 : 50) // Смещение для анимации
                                .opacity(isListVisible ? 1 : 0) // Прозрачность для анимации
                                .animation(
                                    .easeInOut(duration: 0.5).delay(Double(index) * 0.1),
                                    value: isListVisible
                                )
                            }
                            .buttonStyle(PlainButtonStyle()) // Убираем стандартный стиль кнопки
                        }
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Поиск")
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
        .onAppear {
            isListVisible = true // Запускаем анимацию появления списка
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(recipeData: RecipeData(), selectedTab: .constant(1))
    }
} 
