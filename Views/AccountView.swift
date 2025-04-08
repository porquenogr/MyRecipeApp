import SwiftUI

struct AccountView: View {
    @Binding var selectedTab: Int // Для сброса вкладки при возвращении
    @Environment(\.presentationMode) private var presentationMode // Для управления навигацией
    
    // Получаем имя пользователя из UserDefaults
    private var username: String {
        UserDefaults.standard.string(forKey: "username") ?? "user"
    }
    
    var body: some View {
        ZStack {
            // Бежевый градиентный фон, как в MainView
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Фото профиля
                    Image("profile_photo") // Используем изображение из Assets
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(radius: 5)
                        .padding(.top, 20)
                    
                    // Имя пользователя
                    Text(username)
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(.primary)
                    
                    // Разделитель
                    Divider()
                        .padding(.horizontal)
                    
                    // Заглушка для будущих функций
                    VStack(spacing: 15) {
                        Text("Настройки профиля")
                            .font(.custom("AvenirNext-Medium", size: 18))
                            .foregroundColor(.primary)
                        
                        Text("Здесь скоро появятся настройки!")
                            .font(.custom("AvenirNext-Regular", size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom, 80) // Нижний отступ для избежания перекрытия с навигационной панелью
            }
        }
        .navigationTitle("Профиль")
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

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(selectedTab: .constant(3))
    }
}
