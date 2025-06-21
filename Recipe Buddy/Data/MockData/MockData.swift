import Foundation

// MARK: - Mock IDs
struct MockData {
    static let currentUserId = UUID()
    static let otherUserId = UUID()
}


// MARK: - Category Mock Data
extension Category {
    static var mockData: [Category] {
        [
            Category(id: UUID(), name: "Ana Yemek"),
            Category(id: UUID(), name: "Çorba"),
            Category(id: UUID(), name: "Salata"),
            Category(id: UUID(), name: "Tatlı"),
            Category(id: UUID(), name: "Meze"),
            Category(id: UUID(), name: "Hamur İşi"),
            Category(id: UUID(), name: "Zeytinyağlılar"),
            Category(id: UUID(), name: "Kahvaltılık"),
            Category(id: UUID(), name: "İçecek")
        ]
    }
}


// MARK: - Ingredient Mock Data
extension Ingredient {
    static var mockData: [Ingredient] {
        [
            Ingredient(id: UUID(), name: "Kuzu Kuşbaşı"),
            Ingredient(id: UUID(), name: "Dana Kıyma"),
            Ingredient(id: UUID(), name: "Tavuk Göğsü"),
            Ingredient(id: UUID(), name: "Yoğurt"),
            Ingredient(id: UUID(), name: "Tereyağı"),
            Ingredient(id: UUID(), name: "Labne Peyniri"),
            Ingredient(id: UUID(), name: "Yumurta"),
            Ingredient(id: UUID(), name: "Domates"),
            Ingredient(id: UUID(), name: "Soğan"),
            Ingredient(id: UUID(), name: "Sarımsak"),
            Ingredient(id: UUID(), name: "Limon"),
            Ingredient(id: UUID(), name: "Toz Şeker"),
            Ingredient(id: UUID(), name: "Un"),
            Ingredient(id: UUID(), name: "Pide"),
            Ingredient(id: UUID(), name: "Bisküvi")
        ]
    }
}


// MARK: - Recipe Mock Data
extension Recipe {
    
    static var mockOwnedByCurrentUser: Recipe {
        let categories = Category.mockData
        let ingredients = Ingredient.mockData
        
        return Recipe(
            id: UUID(),
            name: "Ev Yapımı İskender",
            description: "Restoranları aratmayan, ev yapımı, bol tereyağlı, enfes bir İskender tarifi. Yanında közlenmiş domates ve biberle servis edilir.",
            ingredients: [
                RecipeIngredientJoin(id: 1, amount: 500, unit: "gr", ingredient: ingredients.first(where: { $0.name == "Kuzu Kuşbaşı" })!),
                RecipeIngredientJoin(id: 2, amount: 2, unit: "adet", ingredient: ingredients.first(where: { $0.name == "Pide" })!),
                RecipeIngredientJoin(id: 3, amount: 3, unit: "yemek kaşığı", ingredient: ingredients.first(where: { $0.name == "Tereyağı" })!),
                RecipeIngredientJoin(id: 4, amount: 1, unit: "kase", ingredient: ingredients.first(where: { $0.name == "Yoğurt" })!),
                RecipeIngredientJoin(id: 5, amount: 2, unit: "adet", ingredient: ingredients.first(where: { $0.name == "Domates" })!)
            ],
            steps: [
                "Kuzu etlerini ince ince doğrayın ve tavada yüksek ateşte mühürleyin.",
                "Pideleri küp küp doğrayıp servis tabağının altına yayın.",
                "Ayrı bir tavada domatesleri közleyin ve salça ile sos hazırlayın.",
                "Etleri pidelerin üzerine yerleştirin, hazırladığınız domates sosunu gezdirin.",
                "En üste bir kase yoğurt koyun ve kızdırılmış tereyağını dökerek servis yapın."
            ],
            cookingTime: 40,
            servings: 2,
            categories: [
                RecipeCategoryJoin(category: categories.first(where: { $0.name == "Ana Yemek" })!),
                RecipeCategoryJoin(category: categories.first(where: { $0.name == "Et Yemeği" }) ?? Category(id: UUID(), name: "Et Yemeği"))
            ],
            rating: 4.8,
            imageName: "iskender_mock.jpg",
            userId: MockData.currentUserId,
            isPublic: false
        )
    }
}
