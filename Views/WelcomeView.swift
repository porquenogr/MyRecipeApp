import SwiftUI

struct WelcomeView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var name: String = "" // Для регистрации
    @State private var email: String = "" // Для регистрации
    @State private var isRegisterMode: Bool = false // Переключение между режимами
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToMain: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background_illustrations")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Легкие и простые рецепты на каждый день")
                        .font(.custom("AvenirNext-Bold", size: 24))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Переключатель режимов
                    Picker("Режим", selection: $isRegisterMode) {
                        Text("Войти").tag(false)
                        Text("Зарегистрироваться").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 50)
                    
                    // Поля для регистрации (показываются только в режиме регистрации)
                    if isRegisterMode {
                        // Поле для имени
                        ZStack(alignment: .leading) {
                            TextField("Имя", text: $name)
                                .font(.custom("AvenirNext-Regular", size: 18))
                                .padding(10)
                                .padding(.leading, 40) // Отступ слева для иконки
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(5)
                                .keyboardType(.asciiCapable)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .padding(.leading, 15)
                        }
                        .padding(.horizontal, 50)
                        
                        // Поле для почты
                        ZStack(alignment: .leading) {
                            TextField("Почта", text: $email)
                                .font(.custom("AvenirNext-Regular", size: 18))
                                .padding(10)
                                .padding(.leading, 40) // Отступ слева для иконки
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(5)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                            
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .padding(.leading, 15)
                        }
                        .padding(.horizontal, 50)
                    }
                    
                    // Поле для имени пользователя (для входа или регистрации)
                    ZStack(alignment: .leading) {
                        TextField("User", text: $username)
                            .font(.custom("AvenirNext-Regular", size: 18))
                            .padding(10)
                            .padding(.leading, 40) // Отступ слева для иконки
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(5)
                            .keyboardType(.asciiCapable)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .padding(.leading, 15)
                    }
                    .padding(.horizontal, 50)
                    
                    // Поле для пароля (для входа или регистрации)
                    ZStack(alignment: .leading) {
                        SecureField("Password", text: $password)
                            .font(.custom("AvenirNext-Regular", size: 18))
                            .padding(10)
                            .padding(.leading, 40) // Отступ слева для иконки
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(5)
                            .keyboardType(.asciiCapable)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .padding(.leading, 15)
                    }
                    .padding(.horizontal, 50)
                    
                    // Кнопка действия (меняется в зависимости от режима)
                    Button(action: {
                        if isRegisterMode {
                            // Режим регистрации
                            if name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty {
                                alertMessage = "Пожалуйста, заполните все поля"
                                showingAlert = true
                            } else {
                                UserDefaults.standard.set(username, forKey: "username")
                                alertMessage = "Аккаунт создан! Теперь войдите."
                                showingAlert = true
                                isRegisterMode = false // Переключаем обратно в режим входа
                                name = ""
                                email = ""
                                username = ""
                                password = ""
                            }
                        } else {
                            // Режим входа
                            if username == "user" && password == "123" {
                                UserDefaults.standard.set(username, forKey: "username")
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
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
                .navigationDestination(isPresented: $navigateToMain) {
                    MainView()
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(isRegisterMode ? "Успех" : "Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
