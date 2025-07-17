import Foundation

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
