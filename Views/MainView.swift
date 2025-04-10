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

// Главный экран
struct MainView: View {
    @StateObject private var recipeData = RecipeData()
    @State private var selectedTab: Int = 0 // Для нижней навигационной панели
    @State private var isRecipesVisible: Bool = false // Для анимации карточек
    @State private var isFactVisible: Bool = false // Для анимации факта дня
    
    // Массив кулинарных фактов
    private let culinaryFacts = [
        "Авокадо — это ягода, а не овощ!",
        "Первая пицца Маргарита была создана в 1889 году в честь королевы Италии.",
        "Мёд никогда не портится благодаря своим природным консервантам.",
        "Самый дорогой в мире кофе — Копи Лювак — делают из зёрен, которые прошли через пищеварительную систему циветты.",
        "Шоколад был впервые использован как напиток в цивилизации майя.",
        "Помидоры изначально считались ядовитыми в Европе и использовались только как украшение.",
        "Шафран — самая дорогая специя в мире, дороже золота по весу!"
    ]
    
    // Получаем факт дня
    private var factOfTheDay: String {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let factIndex = (dayOfYear - 1) % culinaryFacts.count
        return culinaryFacts[factIndex]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Бежевый градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Приветствие (без тени)
                        Text(greetingMessage())
                            .font(.custom("AvenirNext-Bold", size: 24))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Секция "Featured" (Рецепт дня)
                        FeaturedSection(recipeData: recipeData)
                            .padding(.horizontal)
                            .shadow(radius: 5)
                        
                        // Секция категорий
                        CategorySection(categories: recipeData.categories, recipeData: recipeData)
                            .padding(.horizontal)
                        
                        // Секция "Кулинарный факт дня"
                        CulinaryFactSection(fact: factOfTheDay, isVisible: isFactVisible)
                            .padding(.horizontal)
                        
                        // Секция "Популярные рецепты"
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Популярные рецепты")
                                    .font(.custom("AvenirNext-Bold", size: 20))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                NavigationLink(destination: RandomRecipesListView(recipeData: recipeData)) {
                                    Text("Все")
                                        .font(.custom("AvenirNext-Medium", size: 16))
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .frame(minWidth: 50)
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(recipeData.popularRecipes.indices, id: \.self) { index in // Используем popularRecipes
                                        NavigationLink(destination: RecipeDetailView(recipe: recipeData.popularRecipes[index], recipeData: recipeData)) {
                                            RecipeCard(recipe: recipeData.popularRecipes[index], recipeData: recipeData)
                                                .opacity(isRecipesVisible ? 1 : 0)
                                                .scaleEffect(isRecipesVisible ? 1 : 0.8)
                                                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.1), value: isRecipesVisible)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 80) // Нижний отступ для избежания перекрытия с навигационной панелью
                }
                
                // Нижняя навигационная панель
                VStack {
                    Spacer()
                    HStack {
                        // Домик (Home)
                        Button(action: {
                            selectedTab = 0
                        }) {
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(selectedTab == 0 ? .black : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Поиск (Search)
                        NavigationLink(destination: SearchView(recipeData: recipeData, selectedTab: $selectedTab)) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(selectedTab == 1 ? .black : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .simultaneousGesture(TapGesture().onEnded {
                            selectedTab = 1
                        })
                        
                        // Избранное (Favorites)
                        NavigationLink(destination: FavoritesListView(recipeData: recipeData, selectedTab: $selectedTab)) {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(selectedTab == 2 ? .black : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .simultaneousGesture(TapGesture().onEnded {
                            selectedTab = 2
                        })
                        
                        // Аккаунт (Account)
                        NavigationLink(destination: AccountView(selectedTab: $selectedTab)) {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(selectedTab == 3 ? .black : .gray)
                        }
                        .frame(maxWidth: .infinity)
                        .simultaneousGesture(TapGesture().onEnded {
                            selectedTab = 3
                        })
                    }
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .shadow(radius: 5)
                }
            }
            .onAppear {
                isRecipesVisible = true // Запускаем анимацию карточек
                isFactVisible = true // Запускаем анимацию факта дня
            }
        }
    }
    
    // Приветствие в зависимости от времени дня
    private func greetingMessage() -> String {
        let username = UserDefaults.standard.string(forKey: "username") ?? "user"
        let hour = Calendar.current.component(.hour, from: Date())
        
        let greeting: String
        switch hour {
        case 0..<6:
            greeting = "Доброй ночи"
        case 6..<12:
            greeting = "Доброе утро"
        case 12..<18:
            greeting = "Добрый день"
        default:
            greeting = "Добрый вечер"
        }
        
        return "\(greeting), \(username)!"
    }
}

// Новая секция "Кулинарный факт дня"
struct CulinaryFactSection: View {
    let fact: String
    var isVisible: Bool
    
    var body: some View {
        ZStack {
            // Лёгкий градиентный фон для карточки
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.93, blue: 0.87), Color(red: 0.90, green: 0.87, blue: 0.77)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(15)
            .shadow(radius: 3)
            
            // Содержимое карточки
            VStack(alignment: .center, spacing: 5) {
                // Текст
                Text("Интересный факт дня:")
                    .font(.custom("AvenirNext-Bold", size: 18))
                    .foregroundColor(.primary)
                
                Text(fact)
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.9)
        .animation(.easeInOut(duration: 0.5), value: isVisible)
    }
}

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

// Экран списка 10 случайных рецептов (по 2 из каждой категории)
struct RandomRecipesListView: View {
    @ObservedObject var recipeData: RecipeData
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(recipeData.popularRecipes) { recipe in // Используем popularRecipes
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, recipeData: recipeData)) {
                        RecipeCard(recipe: recipe, recipeData: recipeData)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Популярные рецепты")
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

// Компонент для карточки рецепта с кнопкой "Избранное" в углу
struct RecipeCard: View {
    let recipe: Recipe
    @ObservedObject var recipeData: RecipeData
    @State private var isFavorite: Bool
    
    init(recipe: Recipe, recipeData: RecipeData) {
        self.recipe = recipe
        self.recipeData = recipeData
        self._isFavorite = State(initialValue: recipe.favorites)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image(recipe.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 100)
                    .cornerRadius(15)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                // Область для названия с фиксированной высотой
                Text(recipe.name)
                    .font(.custom("AvenirNext-Medium", size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 40)
                    .padding(.top, 5)
                    .padding(.horizontal, 5)
            }
            .frame(width: 150, height: 145)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 3)
            
            // Кнопка "Избранное" в правом верхнем углу
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isFavorite.toggle()
                            // Обновляем состояние в recipeData
                            if var categoryRecipes = recipeData.recipes[recipe.category] {
                                if let index = categoryRecipes.firstIndex(where: { $0.id == recipe.id }) {
                                    categoryRecipes[index].favorites = isFavorite
                                    recipeData.recipes[recipe.category] = categoryRecipes
                                    recipeData.saveFavorites()
                                }
                            }
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(isFavorite ? .red : .gray)
                            .scaleEffect(isFavorite ? 1.2 : 1.0)
                            .padding(5)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                Spacer()
            }
            .frame(width: 150, height: 100, alignment: .topTrailing)
            .padding(.top, 2)
            .padding(.trailing, 5)
        }
    }
}

// Экран с деталями рецепта
struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var recipeData: RecipeData
    @State private var isFavorite: Bool
    
    init(recipe: Recipe, recipeData: RecipeData) {
        self.recipe = recipe
        self.recipeData = recipeData
        self._isFavorite = State(initialValue: recipe.favorites)
    }
    
    var body: some View {
        ZStack {
            // Фоновый градиент
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Изображение рецепта с фиксированным размером
                    ZStack {
                        Image(recipe.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(15)
                            .clipped()
                            .padding(.horizontal)
                            .shadow(radius: 5)
                        
                        // Кнопка "Избранное" в правом верхнем углу
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isFavorite.toggle()
                                        // Обновляем состояние в recipeData
                                        if var categoryRecipes = recipeData.recipes[recipe.category] {
                                            if let index = categoryRecipes.firstIndex(where: { $0.id == recipe.id }) {
                                                categoryRecipes[index].favorites = isFavorite
                                                recipeData.recipes[recipe.category] = categoryRecipes
                                                recipeData.saveFavorites()
                                            }
                                        }
                                    }
                                }) {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(isFavorite ? .red : .gray)
                                        .scaleEffect(isFavorite ? 1.2 : 1.0)
                                        .padding(10)
                                        .background(Color.white.opacity(0.9))
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                            }
                            Spacer()
                        }
                        .frame(height: 300, alignment: .topTrailing)
                        .padding(.top, 10)
                        .padding(.trailing, 20)
                    }
                    
                    // Название рецепта (без тени)
                    Text(recipe.name)
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    // Ингредиенты (без тени)
                    Text("Ингредиенты:")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                            .font(.custom("AvenirNext-Regular", size: 16))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Шаги приготовления (без тени)
                    Text("Шаги:")
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                            .font(.custom("AvenirNext-Regular", size: 16))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .ignoresSafeArea(edges: .bottom) // Добавили игнорирование нижней безопасной области
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Расширение для закругления только определённых углов
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
