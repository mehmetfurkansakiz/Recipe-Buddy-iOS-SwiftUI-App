import Foundation

struct Recipe: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let ingredients: [RecipeIngredient]
    let steps: [String]
    let cookingTime: Int
    let servings: Int
    let categories: [Category]
    let rating: Double
    let imageName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

struct RecipeIngredient: Codable, Identifiable {
    let id: Int
    let ingredient: Ingredient
    let amount: Double
    let unit: String
}

struct Ingredient: Codable, Identifiable {
    let id: UUID
    let name: String
}

struct Category: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct ShoppingItem: Codable, Identifiable {
    let id: UUID
    let ingredient: Ingredient
    var amount: Double
    let unit: String
    let userId: UUID?
    var isChecked: Bool = false
}
