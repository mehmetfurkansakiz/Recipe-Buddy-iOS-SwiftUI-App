//
//  HomeViewModel.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var categories: [Category] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Category?
    @Published var showShoppingList: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty ||
                recipe.name.lowercased().contains(searchText.lowercased())

            let matchesCategory = selectedCategory == nil ||
                recipe.categories.contains(where: { $0.id == selectedCategory?.id })

            return matchesSearch && matchesCategory
        }
    }
    
    init() {
        setupCategories()
    }
    
    func setupCategories() {
        categories = [
            Category(id: UUID(), name: "Ana Yemek"),
            Category(id: UUID(), name: "Çorba"),
            Category(id: UUID(), name: "Salata"),
            Category(id: UUID(), name: "Tatlı"),
            Category(id: UUID(), name: "Atıştırmalık"),
            Category(id: UUID(), name: "İçecek")
        ]
    }
    
    func loadRecipes() {
        let category1 = categories[0]
        let category2 = categories[3]
        let category3 = categories[2]
        
        let kiymalik = Ingredient(id: UUID(), name: "Kıyma")
        let sogan = Ingredient(id: UUID(), name: "Soğan")
        let sarimsak = Ingredient(id: UUID(), name: "Sarımsak")
        let tuz = Ingredient(id: UUID(), name: "Tuz")
        
        let kofteIngredients = [
            RecipeIngredient(id: 1, ingredient: kiymalik, amount: 500, unit: "gr"),
            RecipeIngredient(id: 2, ingredient: sogan, amount: 1, unit: "adet"),
            RecipeIngredient(id: 3, ingredient: sarimsak, amount: 2, unit: "diş"),
            RecipeIngredient(id: 4, ingredient: tuz, amount: 1, unit: "tatlı kaşığı")
        ]
        
        let ciko = Ingredient(id: UUID(), name: "Bitter çikolata")
        let tereyagi = Ingredient(id: UUID(), name: "Tereyağı")
        let yumurta = Ingredient(id: UUID(), name: "Yumurta")
        let seker = Ingredient(id: UUID(), name: "Toz şeker")
        let un = Ingredient(id: UUID(), name: "Un")
        
        let brownieIngredients = [
            RecipeIngredient(id: 5, ingredient: ciko, amount: 200, unit: "gr"),
            RecipeIngredient(id: 6, ingredient: tereyagi, amount: 150, unit: "gr"),
            RecipeIngredient(id: 7, ingredient: yumurta, amount: 3, unit: "adet"),
            RecipeIngredient(id: 8, ingredient: seker, amount: 200, unit: "gr"),
            RecipeIngredient(id: 9, ingredient: un, amount: 100, unit: "gr")
        ]
        
        let marul = Ingredient(id: UUID(), name: "Marul")
        let domates = Ingredient(id: UUID(), name: "Domates")
        let salatalik = Ingredient(id: UUID(), name: "Salatalık")
        
        let salataIngredients = [
            RecipeIngredient(id: 10, ingredient: marul, amount: 1, unit: "adet"),
            RecipeIngredient(id: 11, ingredient: domates, amount: 2, unit: "adet"),
            RecipeIngredient(id: 12, ingredient: salatalik, amount: 1, unit: "adet")
        ]
        
        recipes = [
            Recipe(
                id: UUID(),
                name: "Köfte",
                description: "Lezzetli ev yapımı köfte tarifi",
                ingredients: kofteIngredients,
                steps: [
                    "Kıymayı geniş bir kaba alın.",
                    "Soğan ve sarımsağı ince ince doğrayın ve kıymaya ekleyin.",
                    "Tüm malzemeleri iyice yoğurun.",
                    "Köfteleri şekillendirin ve pişirin."
                ],
                cookingTime: 30,
                servings: 4,
                categories: [category1],
                rating: 4.7,
                imageName: "kofte"
            ),
            Recipe(
                id: UUID(),
                name: "Çikolatalı Brownie",
                description: "Dışı çıtır içi yumuşacık brownie tarifi",
                ingredients: brownieIngredients,
                steps: [
                    "Çikolata ve tereyağını benmari usulü eritin.",
                    "Yumurta ve şekeri çırpın.",
                    "Tüm malzemeleri karıştırın.",
                    "180 derece fırında 25 dakika pişirin."
                ],
                cookingTime: 40,
                servings: 8,
                categories: [category2],
                rating: 4.9,
                imageName: "brownie"
            ),
            Recipe(
                id: UUID(),
                name: "Salata",
                description: "Taze sebzelerle hazırlanan sağlıklı bir salata",
                ingredients: salataIngredients,
                steps: [
                    "Marulu doğrayın.",
                    "Domates ve salatalığı küp küp kesin.",
                    "Tüm malzemeleri karıştırın."
                ],
                cookingTime: 10,
                servings: 2,
                categories: [category1, category3],
                rating: 4.5,
                imageName: "salata"
            )
        ]
    }
}
