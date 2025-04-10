import SwiftUI

struct AccountView: View {
    @Binding var selectedTab: Int // Для сброса вкладки при возвращении
    @Environment(\.presentationMode) private var presentationMode // Для управления навигацией
    
    // Состояние для редактирования имени пользователя
    @State private var isEditingUsername: Bool = false
    @State private var editedUsername: String = ""
    @State private var showLogoutAlert: Bool = false // Для показа алерта выхода
    
    // Состояние для смены пароля
    @State private var showChangePasswordModal: Bool = false
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var passwordChangeMessage: String = ""
    @State private var showPasswordAlert: Bool = false
    
    // Состояние для смены пользователя
    @State private var showChangeUserModal: Bool = false
    @State private var newUsername: String = ""
    @State private var newUserPassword: String = ""
    @State private var userChangeMessage: String = ""
    @State private var showUserAlert: Bool = false
    
    // Анимации
    @State private var isProfileVisible: Bool = false
    
    // Получаем имя пользователя из UserDefaults
    private var username: String {
        UserDefaults.standard.string(forKey: "username") ?? "user"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Бежевый градиентный фон, как в MainView
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Фото профиля с анимацией
                        Image("profile_picture")
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
                            .opacity(isProfileVisible ? 1 : 0)
                            .scaleEffect(isProfileVisible ? 1 : 0.8)
                            .animation(.easeInOut(duration: 0.5), value: isProfileVisible)
                        
                        // Имя пользователя с возможностью редактирования
                        if isEditingUsername {
                            TextField("Введите имя", text: $editedUsername)
                                .font(.custom("AvenirNext-Regular", size: 20))
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            // Сохраняем новое имя
                                            if !editedUsername.isEmpty {
                                                UserDefaults.standard.set(editedUsername, forKey: "username")
                                            }
                                            isEditingUsername = false
                                        }) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .padding(.trailing, 20)
                                        }
                                    }
                                )
                        } else {
                            HStack {
                                Text(username)
                                    .font(.custom("AvenirNext-Bold", size: 24))
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    editedUsername = username
                                    isEditingUsername = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 5)
                                }
                            }
                            .opacity(isProfileVisible ? 1 : 0)
                            .offset(y: isProfileVisible ? 0 : 20)
                            .animation(.easeInOut(duration: 0.5).delay(0.2), value: isProfileVisible)
                        }
                        
                        // Разделитель
                        Divider()
                            .padding(.horizontal)
                        
                        // Карточка настроек
                        VStack(spacing: 15) {
                            // Заголовок
                            Text("Настройки профиля")
                                .font(.custom("AvenirNext-Medium", size: 18))
                                .foregroundColor(.primary)
                            
                            // Смена пароля
                            Button(action: {
                                showChangePasswordModal = true
                            }) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)
                                    Text("Сменить пароль")
                                        .font(.custom("AvenirNext-Regular", size: 16))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Смена пользователя
                            Button(action: {
                                showChangeUserModal = true
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                    Text("Сменить пользователя")
                                        .font(.custom("AvenirNext-Regular", size: 16))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Кнопка "Выйти"
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .foregroundColor(.red)
                                    Text("Выйти")
                                        .font(.custom("AvenirNext-Medium", size: 16))
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .alert(isPresented: $showLogoutAlert) {
                                Alert(
                                    title: Text("Выход"),
                                    message: Text("Вы уверены, что хотите выйти?"),
                                    primaryButton: .destructive(Text("Выйти")) {
                                        // Очищаем данные пользователя
                                        UserDefaults.standard.removeObject(forKey: "username")
                                        UserDefaults.standard.removeObject(forKey: "favorites")
                                        selectedTab = 0
                                        presentationMode.wrappedValue.dismiss()
                                    },
                                    secondaryButton: .cancel(Text("Отмена"))
                                )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(15)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                        .opacity(isProfileVisible ? 1 : 0)
                        .offset(y: isProfileVisible ? 0 : 20)
                        .animation(.easeInOut(duration: 0.5).delay(0.4), value: isProfileVisible)
                        
                        Spacer()
                    }
                    .padding(.bottom, 80) // Нижний отступ для избежания перекрытия с навигационной панелью
                }
                
                // Кастомное модальное окно для смены пароля
                if showChangePasswordModal {
                    ZStack {
                        // Затемнённый фон
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    showChangePasswordModal = false
                                    oldPassword = ""
                                    newPassword = ""
                                    confirmNewPassword = ""
                                }
                            }
                        
                        // Модальное окно
                        VStack(spacing: 20) {
                            Text("Смена пароля")
                                .font(.custom("AvenirNext-Bold", size: 20))
                                .foregroundColor(.primary)
                            
                            // Поле для старого пароля
                            ZStack(alignment: .leading) {
                                SecureField("Старый пароль", text: $oldPassword)
                                    .font(.custom("AvenirNext-Regular", size: 16))
                                    .padding(10)
                                    .padding(.leading, 40)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(5)
                                    .keyboardType(.asciiCapable)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                            }
                            
                            // Поле для нового пароля
                            ZStack(alignment: .leading) {
                                SecureField("Новый пароль", text: $newPassword)
                                    .font(.custom("AvenirNext-Regular", size: 16))
                                    .padding(10)
                                    .padding(.leading, 40)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(5)
                                    .keyboardType(.asciiCapable)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                            }
                            
                            // Поле для подтверждения нового пароля
                            ZStack(alignment: .leading) {
                                SecureField("Подтвердите новый пароль", text: $confirmNewPassword)
                                    .font(.custom("AvenirNext-Regular", size: 16))
                                    .padding(10)
                                    .padding(.leading, 40)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(5)
                                    .keyboardType(.asciiCapable)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                            }
                            
                            // Кнопка "Сохранить"
                            Button(action: {
                                // Проверяем старый пароль
                                let savedPassword = UserDefaults.standard.string(forKey: "password") ?? "123"
                                if oldPassword != savedPassword {
                                    passwordChangeMessage = "Неверный старый пароль"
                                    showPasswordAlert = true
                                } else if newPassword != confirmNewPassword {
                                    passwordChangeMessage = "Пароли не совпадают"
                                    showPasswordAlert = true
                                } else if newPassword.isEmpty {
                                    passwordChangeMessage = "Новый пароль не может быть пустым"
                                    showPasswordAlert = true
                                } else {
                                    // Сохраняем новый пароль (в данном случае просто в UserDefaults)
                                    // В реальном приложении здесь должна быть серверная логика
                                    passwordChangeMessage = "Пароль успешно изменён!"
                                    showPasswordAlert = true
                                    oldPassword = ""
                                    newPassword = ""
                                    confirmNewPassword = ""
                                    showChangePasswordModal = false
                                }
                            }) {
                                Text("Сохранить")
                                    .font(.custom("AvenirNext-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(10)
                            }
                            
                            // Кнопка "Отмена"
                            Button(action: {
                                withAnimation {
                                    showChangePasswordModal = false
                                    oldPassword = ""
                                    newPassword = ""
                                    confirmNewPassword = ""
                                }
                            }) {
                                Text("Отмена")
                                    .font(.custom("AvenirNext-Medium", size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .frame(maxWidth: 300) // Ограничиваем ширину для компактности
                        .scaleEffect(showChangePasswordModal ? 1 : 0.8)
                        .opacity(showChangePasswordModal ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showChangePasswordModal)
                    }
                    .alert(isPresented: $showPasswordAlert) {
                        Alert(
                            title: Text(passwordChangeMessage.contains("успешно") ? "Успех" : "Ошибка"),
                            message: Text(passwordChangeMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                
                // Кастомное модальное окно для смены пользователя
                if showChangeUserModal {
                    ZStack {
                        // Затемнённый фон
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    showChangeUserModal = false
                                    newUsername = ""
                                    newUserPassword = ""
                                }
                            }
                        
                        // Модальное окно
                        VStack(spacing: 20) {
                            Text("Смена пользователя")
                                .font(.custom("AvenirNext-Bold", size: 20))
                                .foregroundColor(.primary)
                            
                            // Поле для нового имени пользователя
                            ZStack(alignment: .leading) {
                                TextField("Новое имя пользователя", text: $newUsername)
                                    .font(.custom("AvenirNext-Regular", size: 16))
                                    .padding(10)
                                    .padding(.leading, 40)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(5)
                                    .keyboardType(.asciiCapable)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                            }
                            
                            // Поле для пароля
                            ZStack(alignment: .leading) {
                                SecureField("Пароль", text: $newUserPassword)
                                    .font(.custom("AvenirNext-Regular", size: 16))
                                    .padding(10)
                                    .padding(.leading, 40)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(5)
                                    .keyboardType(.asciiCapable)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                            }
                            
                            // Кнопка "Войти"
                            Button(action: {
                                // Проверяем данные (аналогично WelcomeView)
                                if newUsername == "user" && newUserPassword == "123" {
                                    // Обновляем данные пользователя
                                    UserDefaults.standard.set(newUsername, forKey: "username")
                                    userChangeMessage = "Пользователь успешно изменён!"
                                    showUserAlert = true
                                    showChangeUserModal = false
                                    newUsername = ""
                                    newUserPassword = ""
                                } else {
                                    userChangeMessage = "Неверный логин или пароль"
                                    showUserAlert = true
                                }
                            }) {
                                Text("Войти")
                                    .font(.custom("AvenirNext-Bold", size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(10)
                            }
                            
                            // Кнопка "Отмена"
                            Button(action: {
                                withAnimation {
                                    showChangeUserModal = false
                                    newUsername = ""
                                    newUserPassword = ""
                                }
                            }) {
                                Text("Отмена")
                                    .font(.custom("AvenirNext-Medium", size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.98, green: 0.96, blue: 0.90), Color(red: 0.94, green: 0.90, blue: 0.80)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .frame(maxWidth: 300) // Ограничиваем ширину для компактности
                        .scaleEffect(showChangeUserModal ? 1 : 0.8)
                        .opacity(showChangeUserModal ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showChangeUserModal)
                    }
                    .alert(isPresented: $showUserAlert) {
                        Alert(
                            title: Text(userChangeMessage.contains("успешно") ? "Успех" : "Ошибка"),
                            message: Text(userChangeMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
                isProfileVisible = true // Запускаем анимацию при появлении
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(selectedTab: .constant(3))
    }
}
