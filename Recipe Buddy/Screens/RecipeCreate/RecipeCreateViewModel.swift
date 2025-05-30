import SwiftUI

class RecipeCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var servings: Int = 4   // default start
    @Published var cookingTime: Int = 30 // default start
    @Published var steps: [String] = [""]
    @Published var ingredients: [SimpleIngredientInput] = [SimpleIngredientInput()]
    @Published var categories: [Category] = []
    @Published var showSuccess: Bool = false
    
    let servingsOptions = Array(1...20)
    let timeOptions: [Int] = Array(stride(from: 5, through: 240, by: 5))

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !ingredients.contains(where: { $0.name.trimmingCharacters(in: .whitespaces).isEmpty }) &&
        !steps.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty })
    }

    func addIngredient() {
        ingredients.append(SimpleIngredientInput())
    }
    func removeIngredient(at index: Int) {
        if ingredients.count > 1 {
            ingredients.remove(at: index)
        }
    }
    func addStep() { steps.append("") }
    func removeStep(at index: Int) {
        if steps.count > 1 { steps.remove(at: index) }
    }

    func toRecipe() -> Recipe {
        Recipe(
            id: UUID(),
            name: name,
            description: description,
            ingredients: ingredients.enumerated().map { idx, ing in
                RecipeIngredient(
                    id: idx,
                    ingredient: Ingredient(id: UUID(), name: ing.name),
                    amount: Double(ing.amount) ?? 1.0,
                    unit: ing.unit
                )
            },
            steps: steps,
            cookingTime: cookingTime,
            servings: servings,
            categories: categories,
            rating: 0.0,
            imageName: ""
        )
    }

    func saveAction() {
        guard isValid else { return }
        showSuccess = true
        // buraya delegate veya listeye ekleme vs. kodu ekleyebilirsiniz!
    }
}

struct SimpleIngredientInput: Hashable {
    var name: String = ""
    var amount: String = ""
    var unit: String = ""
}
