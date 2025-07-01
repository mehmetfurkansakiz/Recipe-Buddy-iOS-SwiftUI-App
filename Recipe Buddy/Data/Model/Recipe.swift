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

// Recipe image extension for get image supabase storage
extension Recipe {
    var imagePublicURL: URL? {
        let urlString = Secrets.supabaseURL
                    .absoluteString
                    .replacingOccurrences(of: "/rest/v1", with: "")
        let fullURLString = "\(urlString)/storage/v1/object/public/recipe-images/\(self.imageName)"
        return URL(string: fullURLString)
    }
}

// SQL query for selecting recipes with related data
extension Recipe {
    static let selectQuery = """
        id, name, description, steps, cooking_time, servings, rating, image_name, user_id, is_public, created_at,
        user:users(id, full_name, username, avatar_url),
        categories:recipe_categories(category:categories(id, name)),
        ingredients:recipe_ingredients(id, amount, unit, ingredient:ingredients(id, name))
    """
}
