import Foundation

struct RecipeIngredientInput: Identifiable, Hashable {
    var id: UUID { ingredient.id }
    var ingredient: Ingredient
    var amount: String = ""
    var unit: String = ""

    static func == (lhs: RecipeIngredientInput, rhs: RecipeIngredientInput) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct NewRecipe: Encodable {
    let name: String
    let description: String
    let cookingTime: Int
    let servings: Int
    let steps: [String]
    let imageName: String
    let userId: UUID
    let isPublic: Bool

    // camelCase -> DB snake_case
    enum CodingKeys: String, CodingKey {
        case name, description, steps, servings
        case cookingTime = "cooking_time"
        case imageName = "image_name"
        case userId = "user_id"
        case isPublic = "is_public"
    }
}

struct NewRecipeIngredient: Encodable {
    let recipeId: UUID
    let ingredientId: UUID
    let amount: Double
    let unit: String
    
    enum CodingKeys: String, CodingKey {
        case amount, unit
        case recipeId = "recipe_id"
        case ingredientId = "ingredient_id"
    }
}

struct NewRecipeCategory: Encodable {
    let recipeId: UUID
    let categoryId: UUID
    
    enum CodingKeys: String, CodingKey {
        case recipeId = "recipe_id"
        case categoryId = "category_id"
    }
}

struct RecipeStep: Identifiable, Hashable {
    let id = UUID()
    var text: String
}
