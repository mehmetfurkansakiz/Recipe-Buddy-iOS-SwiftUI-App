import Foundation

struct RecipeIngredientInput: Identifiable, Hashable {
    var id: UUID { ingredient.id }
    let ingredient: Ingredient
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

    // camelCase -> DB snake_case
    enum CodingKeys: String, CodingKey {
        case name, description, steps, servings
        case cookingTime = "cooking_time"
        case imageName = "image_name"
    }
}

struct NewRecipeIngredient: Encodable {
    let recipeId: UUID
    let ingredientId: UUID
    let amount: Double
    let unit: String
}

struct NewRecipeCategory: Encodable {
    let recipeId: UUID
    let categoryId: UUID
}
