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
            Ingredient(id: UUID(), name: "Limon")
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
            ShoppingList(id: UUID(), name: "Haftalık Pazar Alışverişi", userId: MockData.currentUserId),
            ShoppingList(id: UUID(), name: "Doğum Günü Partisi", userId: MockData.currentUserId)
        ]
    }
}

// MARK: - ShoppingListItem Mock Data
extension ShoppingListItem {
    static func mocks(for list: ShoppingList) -> [ShoppingListItem] {
        let ingredients = Ingredient.mockData
        
        if list.name.contains("Haftalık") {
            return [
                ShoppingListItem(id: UUID(), ingredient: ingredients.first { $0.name == "Tavuk Göğsü" }!, amount: 1, unit: "kg", userId: list.userId, isChecked: false),
                ShoppingListItem(id: UUID(), ingredient: ingredients.first { $0.name == "Domates" }!, amount: 500, unit: "gr", userId: list.userId, isChecked: true),
                ShoppingListItem(id: UUID(), ingredient: ingredients.first { $0.name == "Yumurta" }!, amount: 10, unit: "adet", userId: list.userId, isChecked: false)
            ]
        }
        
        if list.name.contains("Parti") {
            return [
                ShoppingListItem(id: UUID(), ingredient: ingredients.first { $0.name == "Labne Peyniri" }!, amount: 600, unit: "gr", userId: list.userId, isChecked: false),
                ShoppingListItem(id: UUID(), ingredient: ingredients.first { $0.name == "Bisküvi" }!, amount: 2, unit: "paket", userId: list.userId, isChecked: false),
                ShoppingListItem(id: UUID(), ingredient: ingredients.first { $0.name == "Limon" }!, amount: 3, unit: "adet", userId: list.userId, isChecked: true)
            ]
        }
        
        return []
    }
}
