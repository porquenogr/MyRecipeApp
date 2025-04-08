import Foundation

struct Recipe: Codable, Identifiable {
    let id: Int
    let category: String
    let name: String
    let ingredients: [String]
    let steps: [String]
    var favorites: Bool
    let imageName: String
}
