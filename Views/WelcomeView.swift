import SwiftUI
import Security

// Вспомогательный класс для работы с Keychain (безопасное хранение пароля)
class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    // Сохранение пароля в Keychain
    func save(_ value: String, forKey key: String) -> Bool {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            
            // Удаляем старые данные, если они есть
            SecItemDelete(query as CFDictionary)
            
            // Сохраняем новые данные
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }
        return false
    }
    
    // Чтение пароля из Keychain
    func read(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data, let value = String(data: data, encoding: .utf8) {
            return value
        }
        return nil
    }
    
    // Удаление данных из Keychain
    func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

struct WelcomeView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = "" // Для регистрации
    @State private var isRegisterMode: Bool = false // Переключение между входом и регистрацией
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToMain: Bool = false
    @State private var showForgotPasswordModal: Bool = false // Для модального окна "Забыли пароль?"
    @State private var forgotPasswordEmail: String = "" // Для сброса пароля
    @State private var isContentVisible: Bool = false // Для анимации
    
    // Валидация email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Проверка уникальности email
    private func isEmailUnique(_ email: String) -> Bool {
        let existingEmails = UserDefaults.standard.stringArray(forKey: "registeredEmails") ?? []
        return !existingEmails.contains(email)
    }
    
    // Сохранение email в список
    private func saveEmail(_ email: String) {
        var existingEmails = UserDefaults.standard.stringArray(forKey: "registeredEmails") ?? []
        existingEmails.append(email)
        UserDefaults.standard.set(existingEmails, forKey: "registeredEmails")
    }
    
    // Проверка, активна ли кнопка "Зарегистрироваться" (пароль должен быть 6 символов)
    private var isRegisterButtonEnabled: Bool {
        return password.count == 6
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Фоновое изображение из Assets.xcassets
                Image("Image 2")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                // Полупрозрачный слой для улучшения читаемости
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                // Основной контейнер для полей и кнопок
                VStack(spacing: 20) {
                    Spacer() // Центрируем содержимое по вертикали
                    
                    // Заголовок
                    Text("Легкие и простые рецепты на каждый день")
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
                        .opacity(isContentVisible ? 1 : 0)
                        .offset(y: isContentVisible ? 0 : 20)
                        .animation(.easeInOut(duration: 0.5), value: isContentVisible)
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 2, y: 2)
                    
                    // Переключатель режимов (Войти/Зарегистрироваться)
                    Picker("Режим", selection: $isRegisterMode) {
                        Text("Войти").tag(false)
                        Text("Зарегистрироваться").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 50)
                    .opacity(isContentVisible ? 1 : 0)
                    .offset(y: isContentVisible ? 0 : 20)
                    .animation(.easeInOut(duration: 0.5).delay(0.2), value: isContentVisible)
                    
                    // Поле для email (только в режиме регистрации, английская раскладка)
                    if isRegisterMode {
                        ZStack(alignment: .leading) {
                            TextField("Почта", text: Binding(
                                get: { email },
                                set: { newValue in
                                    let filtered = newValue.filter { $0.isASCII } // Только латинские символы
                                    email = filtered
                                }
                            ))
                                .font(.custom("AvenirNext-Regular", size: 18))
                                .padding(12)
                                .padding(.leading, 40)
                                .background(Color(.systemBackground).opacity(0.9))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .keyboardType(.asciiCapable) // Английская раскладка
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .onChange(of: email) { oldValue, newValue in
                                    print("Введено в email: \(newValue)") // Отладка для проверки ввода
                                }
                            
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .padding(.leading, 15)
                        }
                        .padding(.horizontal, 50)
                        .opacity(isContentVisible ? 1 : 0)
                        .offset(y: isContentVisible ? 0 : 20)
                        .animation(.easeInOut(duration: 0.5).delay(0.3), value: isContentVisible)
                    }
                    
                    // Поле для имени пользователя (поддержка кириллицы)
                    ZStack(alignment: .leading) {
                        TextField("Имя пользователя", text: $username)
                            .font(.custom("AvenirNext-Regular", size: 18))
                            .padding(12)
                            .padding(.leading, 40)
                            .background(Color(.systemBackground).opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .keyboardType(.default) // Разрешает переключение на русскую клавиатуру
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .padding(.leading, 15)
                    }
                    .padding(.horizontal, 50)
                    .opacity(isContentVisible ? 1 : 0)
                    .offset(y: isContentVisible ? 0 : 20)
                    .animation(.easeInOut(duration: 0.5).delay(isRegisterMode ? 0.4 : 0.3), value: isContentVisible)
                    
                    // Поле для пароля
                    ZStack(alignment: .leading) {
                        SecureField("Пароль", text: $password)
                            .font(.custom("AvenirNext-Regular", size: 18))
                            .padding(12)
                            .padding(.leading, 40)
                            .background(Color(.systemBackground).opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .keyboardType(.asciiCapable)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .padding(.leading, 15)
                    }
                    .padding(.horizontal, 50)
                    .opacity(isContentVisible ? 1 : 0)
                    .offset(y: isContentVisible ? 0 : 20)
                    .animation(.easeInOut(duration: 0.5).delay(isRegisterMode ? 0.5 : 0.4), value: isContentVisible)
                    
                    // Кнопка "Забыли пароль?" (только в режиме входа)
                    if !isRegisterMode {
                        Button(action: {
                            showForgotPasswordModal = true
                        }) {
                            Text("Забыли пароль?")
                                .font(.custom("AvenirNext-Regular", size: 18))
                                .foregroundColor(.black)
                        }
                        .opacity(isContentVisible ? 1 : 0)
                        .offset(y: isContentVisible ? 0 : 20)
                        .animation(.easeInOut(duration: 0.5).delay(0.5), value: isContentVisible)
                    }
                    
                    // Кнопка действия (Войти/Зарегистрироваться)
                    Button(action: {
                        if isRegisterMode {
                            // Регистрация
                            if username.isEmpty || email.isEmpty || password.isEmpty {
                                alertMessage = "Пожалуйста, заполните все поля"
                                showingAlert = true
                            } else if !isValidEmail(email) {
                                alertMessage = "Некорректный формат email"
                                showingAlert = true
                            } else if !isEmailUnique(email) {
                                alertMessage = "Этот email уже зарегистрирован"
                                showingAlert = true
                            } else if password.count != 6 {
                                alertMessage = "Пароль должен быть ровно 6 символов"
                                showingAlert = true
                            } else {
                                UserDefaults.standard.set(username, forKey: "username")
                                // Сохраняем пароль в Keychain
                                if KeychainHelper.shared.save(password, forKey: "password") {
                                    saveEmail(email) // Сохраняем email
                                    alertMessage = "Аккаунт создан! Теперь войдите."
                                    showingAlert = true
                                    isRegisterMode = false
                                    email = ""
                                    username = ""
                                    password = ""
                                } else {
                                    alertMessage = "Ошибка при сохранении пароля"
                                    showingAlert = true
                                }
                            }
                        } else {
                            // Вход
                            let savedPassword = KeychainHelper.shared.read("password") ?? "123"
                            if username == "user" && password == savedPassword {
                                UserDefaults.standard.set(username, forKey: "username")
                                print("Переход к MainView") // Отладка для диагностики краша
                                navigateToMain = true
                            } else {
                                alertMessage = "Неверный логин или пароль"
                                showingAlert = true
                            }
                        }
                    }) {
                        Text(isRegisterMode ? "Зарегистрироваться" : "Войти")
                            .font(.custom("AvenirNext-Bold", size: 20))
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 250)
                            .background(
                                isRegisterMode && !isRegisterButtonEnabled ?
                                Color.gray.opacity(0.8) : // Серая, если пароль не 6 символов
                                Color.black.opacity(0.8)  // Чёрная, если всё ок
                            )
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .disabled(isRegisterMode && !isRegisterButtonEnabled) // Отключаем кнопку, если пароль не 6 символов
                    .opacity(isContentVisible ? 1 : 0)
                    .offset(y: isContentVisible ? 0 : 20)
                    .animation(.easeInOut(duration: 0.5).delay(isRegisterMode ? 0.6 : 0.5), value: isContentVisible)
                    
                    Spacer() // Центрируем содержимое по вертикали
                }
                .padding(.bottom, 20)
                
                // Модальное окно для "Забыли пароль?"
                if showForgotPasswordModal {
                    ZStack {
                        // Затемнённый фон
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    showForgotPasswordModal = false
                                    forgotPasswordEmail = ""
                                }
                            }
                        
                        // Модальное окно
                        VStack(spacing: 20) {
                            Text("Сброс пароля")
                                .font(.custom("AvenirNext-Bold", size: 20))
                                .foregroundColor(.primary)
                            
                            // Поле для email
                            ZStack(alignment: .leading) {
                                TextField("Введите email", text: $forgotPasswordEmail)
                                    .font(.custom("AvenirNext-Regular", size: 16))
                                    .padding(12)
                                    .padding(.leading, 40)
                                    .background(Color(.systemBackground).opacity(0.9))
                                    .cornerRadius(10)
                                    .keyboardType(.asciiCapable)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 15)
                            }
                            
                            // Кнопка "Отправить"
                            Button(action: {
                                if !isValidEmail(forgotPasswordEmail) {
                                    alertMessage = "Некорректный формат email"
                                    showingAlert = true
                                } else {
                                    alertMessage = "Инструкции по сбросу пароля отправлены на \(forgotPasswordEmail)"
                                    showingAlert = true
                                    showForgotPasswordModal = false
                                    forgotPasswordEmail = ""
                                }
                            }) {
                                Text("Отправить")
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
                                    showForgotPasswordModal = false
                                    forgotPasswordEmail = ""
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
                        .frame(maxWidth: 300)
                        .scaleEffect(showForgotPasswordModal ? 1 : 0.8)
                        .opacity(showForgotPasswordModal ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showForgotPasswordModal)
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(isRegisterMode ? "Вы с нами?" : "Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $navigateToMain) {
                MainView()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isContentVisible = true // Анимация при появлении экрана
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
