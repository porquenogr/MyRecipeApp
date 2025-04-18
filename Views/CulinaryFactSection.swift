import SwiftUI
//// Новая секция "Кулинарный факт дня"

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
