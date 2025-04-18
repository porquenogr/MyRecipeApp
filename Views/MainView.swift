import SwiftUI

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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
