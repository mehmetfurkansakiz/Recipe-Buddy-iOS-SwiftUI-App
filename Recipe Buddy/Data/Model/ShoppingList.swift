import Foundation

struct ShoppingList: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case userId = "user_id"
    }
}

struct ShoppingListItem: Codable, Identifiable, Hashable {
    let id: UUID
    let ingredient: Ingredient
    var amount: Double
    let unit: String
    let userId: UUID?
    var isChecked: Bool
    
    var formattedAmount: String {
        if amount.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.1f", amount)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, ingredient, amount, unit
        case userId = "user_id"
        case isChecked = "is_checked"
    }
}

struct ShoppingListItemInsert: Encodable {
    let listId: UUID
    let ingredientId: UUID
    let amount: Double
    let unit: String
    
    init(from recipeIngredient: RecipeIngredientJoin, listId: UUID) {
        self.listId = listId
        self.ingredientId = recipeIngredient.ingredient.id
        self.amount = recipeIngredient.amount
        self.unit = recipeIngredient.unit
    }
    
    enum CodingKeys: String, CodingKey {
        case amount, unit
        case listId = "list_id"
        case ingredientId = "ingredient_id"
    }
}
