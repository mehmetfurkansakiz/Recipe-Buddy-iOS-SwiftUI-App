import Foundation

/// models for the Shopping List module
struct ShoppingList: Identifiable, Hashable {
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ShoppingList, rhs: ShoppingList) -> Bool {
        lhs.id == rhs.id
    }
}
/// models for the Recipe Create module
struct RecipeCreate: Identifiable, Hashable {
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecipeCreate, rhs: RecipeCreate) -> Bool {
        lhs.id == rhs.id
    }
}
