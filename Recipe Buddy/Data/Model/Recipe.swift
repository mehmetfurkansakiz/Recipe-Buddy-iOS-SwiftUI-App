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
    let ratingCount: Int?
    let imageName: String
    let userId: UUID
    let isPublic: Bool
    let user: User?
    let createdAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, ingredients, steps, servings, categories, rating, user
        case cookingTime = "cooking_time"
        case ratingCount = "rating_count"
        case imageName = "image_name"
        case userId = "user_id"
        case isPublic = "is_public"
        case createdAt = "created_at"
    }
}

struct RecipeIngredientJoin: Codable, Hashable, Identifiable {
    let id: Int
    let amount: Double
    let unit: String
    let ingredient: Ingredient
    
    var formattedAmount: String {
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.1f", amount)
        }
    }
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

struct NewRating: Encodable {
    let recipeId: UUID
    let userId: UUID
    let rating: Int
    
    enum CodingKeys: String, CodingKey {
        case rating
        case recipeId = "recipe_id"
        case userId = "user_id"
    }
}
