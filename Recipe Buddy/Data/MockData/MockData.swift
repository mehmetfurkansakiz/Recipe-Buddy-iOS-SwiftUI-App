import Foundation

import Foundation

// MARK: - Mock IDs
struct MockData {
    static let currentUserId = UUID()
    static let otherUserId = UUID()
    
    static let currentUser = User(id: currentUserId, fullName: "Furkan Sakız", username: "furkansakiz", avatarUrl: nil)
    static let otherUser = User(id: otherUserId, fullName: "Ayşe Yılmaz", username: "ayseyilmaz", avatarUrl: nil)
}


// MARK: - Category & Ingredient Mock Data
extension Category {
    static var mockData: [Category] {
        [
            Category(id: UUID(), name: "Ana Yemek"),
            Category(id: UUID(), name: "Et Yemeği"),
            Category(id: UUID(), name: "Çorba"),
            Category(id: UUID(), name: "Salata"),
            Category(id: UUID(), name: "Tatlı"),
        ]
    }
}

extension Ingredient {
    static var mockData: [Ingredient] {
        [
            Ingredient(id: UUID(), name: "Kuzu Kuşbaşı"),
            Ingredient(id: UUID(), name: "Kırmızı Mercimek"),
            Ingredient(id: UUID(), name: "Soğan"),
            Ingredient(id: UUID(), name: "Tavuk Göğsü"),
            Ingredient(id: UUID(), name: "Marul"),
            Ingredient(id: UUID(), name: "Labne Peyniri"),
            Ingredient(id: UUID(), name: "Limon"),
            Ingredient(id: UUID(), name: "Domates"),
            Ingredient(id: UUID(), name: "Yumurta"),
            Ingredient(id: UUID(), name: "Bisküvi")
        ]
    }
}


// MARK: - Recipe Mock Data Collection
extension Recipe {
    
    static var allMocks: [Recipe] {
        let categories = Category.mockData
        let ingredients = Ingredient.mockData
        
        return [
            // Tarif 1: Mevcut kullanıcının kendi tarifi
            Recipe(
                id: UUID(), name: "Süzme Mercimek Çorbası",
                description: "Lokanta usulü, besleyici ve lezzetli.",
                ingredients: [
                    RecipeIngredientJoin(id: 1, amount: 1.5, unit: "su bardağı", ingredient: ingredients.first { $0.name == "Kırmızı Mercimek" }!),
                    RecipeIngredientJoin(id: 2, amount: 1, unit: "adet", ingredient: ingredients.first { $0.name == "Soğan" }!)
                ],
                steps: ["Soğanları kavur.", "Mercimekleri ekle.", "Blender'dan geçir."],
                cookingTime: 30, servings: 6,
                categories: [RecipeCategoryJoin(category: categories.first { $0.name == "Çorba" }!)],
                rating: 4.7, ratingCount: 88, imageName: "mock_image_1.jpg",
                userId: MockData.currentUserId,
                isPublic: true,
                user: MockData.currentUser,
                createdAt: Date()
            ),
            
            // Tarif 2: Başkasına ait, favorilere eklenecek bir tarif
            Recipe(
                id: UUID(), name: "Limonlu Cheesecake",
                description: "Ferahlatıcı ve lezzetli.",
                ingredients: [
                    RecipeIngredientJoin(id: 3, amount: 400, unit: "gr", ingredient: ingredients.first { $0.name == "Labne Peyniri" }!),
                    RecipeIngredientJoin(id: 4, amount: 2, unit: "adet", ingredient: ingredients.first { $0.name == "Limon" }!)
                ],
                steps: ["Tabanını hazırla.", "Kremayı çırp.", "Fırında pişir."],
                cookingTime: 90, servings: 8,
                categories: [RecipeCategoryJoin(category: categories.first { $0.name == "Tatlı" }!)],
                rating: 4.8, ratingCount: 210, imageName: "mock_image_2.jpg",
                userId: MockData.otherUserId,
                isPublic: true,
                user: MockData.otherUser,
                createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
            ),
            
            // Tarif 3: Mevcut kullanıcının ikinci tarifi
             Recipe(
                id: UUID(), name: "Tavuklu Sezar Salata",
                description: "Tavuklu, krutonlu, özel sosuyla klasik.",
                ingredients: [
                    RecipeIngredientJoin(id: 5, amount: 1, unit: "adet", ingredient: ingredients.first { $0.name == "Tavuk Göğsü" }!),
                    RecipeIngredientJoin(id: 6, amount: 1, unit: "göbek", ingredient: ingredients.first { $0.name == "Marul" }!)
                ],
                steps: ["Tavukları pişir.", "Marulları doğra.", "Sosu ekle."],
                cookingTime: 25, servings: 2,
                categories: [RecipeCategoryJoin(category: categories.first { $0.name == "Salata" }!)],
                rating: 4.5, ratingCount: 45, imageName: "mock_image_3.jpg",
                userId: MockData.currentUserId,
                isPublic: true,
                user: MockData.currentUser,
                createdAt: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!
            )
        ]
    }
}

// MARK: - ShoppingList Mock Data
extension ShoppingList {
    static var mockLists: [ShoppingList] {
        [
            ShoppingList(id: UUID(), name: "Haftalık Pazar Alışverişi", userId: MockData.currentUserId, itemCount: 3),
            ShoppingList(id: UUID(), name: "Doğum Günü Partisi", userId: MockData.currentUserId, itemCount: 5)
        ]
    }
}

// MARK: - ShoppingListItem Mock Data
extension ShoppingListItem {
    static func mocks(for list: ShoppingList) -> [ShoppingListItem] {
        let ingredients = Ingredient.mockData
        
        // Helper function to safely get an ingredient.
        func getIngredient(named name: String) -> Ingredient {
            return ingredients.first { $0.name == name }!
        }
        
        if list.name.contains("Haftalık") {
            let tavuk = getIngredient(named: "Tavuk Göğsü")
            let domates = getIngredient(named: "Domates")
            let yumurta = getIngredient(named: "Yumurta")
            
            return [
                ShoppingListItem(id: UUID(), name: tavuk.name, amount: 1, unit: "kg", isChecked: false, ingredientId: tavuk.id),
                ShoppingListItem(id: UUID(), name: domates.name, amount: 500, unit: "gr", isChecked: true, ingredientId: domates.id),
                ShoppingListItem(id: UUID(), name: yumurta.name, amount: 10, unit: "adet", isChecked: false, ingredientId: yumurta.id)
            ]
        }
        
        if list.name.contains("Parti") {
            let labne = getIngredient(named: "Labne Peyniri")
            let biskuvi = getIngredient(named: "Bisküvi")
            let limon = getIngredient(named: "Limon")
            
            return [
                ShoppingListItem(id: UUID(), name: labne.name, amount: 600, unit: "gr", isChecked: false, ingredientId: labne.id),
                ShoppingListItem(id: UUID(), name: biskuvi.name, amount: 2, unit: "paket", isChecked: false, ingredientId: biskuvi.id),
                ShoppingListItem(id: UUID(), name: limon.name, amount: 3, unit: "adet", isChecked: true, ingredientId: limon.id)
            ]
        }
        
        return []
    }
}
