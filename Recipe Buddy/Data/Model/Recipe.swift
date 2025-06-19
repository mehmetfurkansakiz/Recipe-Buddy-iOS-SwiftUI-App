import Foundation

struct Recipe: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let ingredients: [RecipeIngredientJoin]
    let steps: [String]
    let cookingTime: Int
    let servings: Int
    let categories: [RecipeCategoryJoin]
    let rating: Double?
    let imageName: String
    let userId: UUID
    let isPublic: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, ingredients, steps, servings, categories, rating
        case cookingTime = "cooking_time"
        case imageName = "image_name"
        case userId = "user_id"
        case isPublic = "is_public"
    }
}

struct RecipeIngredientJoin: Codable, Hashable, Identifiable {
    let id: Int
    let amount: Double
    let unit: String
    let ingredient: Ingredient
}

struct RecipeCategoryJoin: Codable, Hashable, Identifiable {
    var id: UUID { category.id }
    let category: Category
}

struct RecipeID: Decodable {
    let id: UUID
}

struct Ingredient: Codable, Identifiable, Hashable {
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
    
    enum CodingKeys: String, CodingKey {
        case id, ingredient, amount, unit
        case userId = "user_id"
        case isChecked = "is_checked"
    }
}
