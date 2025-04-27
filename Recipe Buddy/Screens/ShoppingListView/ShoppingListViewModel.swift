//
//  ShoppingListViewModel.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import Foundation

class ShoppingListViewModel: ObservableObject {
    @Published var shoppingItems: [ShoppingItem] = []
    @Published var showingShareSheet: Bool = false
    @Published var showingClearAlert: Bool = false
    
    var hasCheckedItems: Bool {
        shoppingItems.contains(where: { $0.isChecked })
    }
    
    // Group items by category
    var groupedItems: [String: [ShoppingItem]] {
        Dictionary(grouping: shoppingItems) { item in
            if item.ingredient.name.contains("et") || item.ingredient.name.contains("tavuk") {
                return "Et & Tavuk"
            } else if item.ingredient.name.contains("süt") || item.ingredient.name.contains("peynir") {
                return "Süt Ürünleri"
            } else if item.ingredient.name.contains("un") || item.ingredient.name.contains("şeker") {
                return "Kuru Gıda"
            } else if item.ingredient.name.contains("domates") || item.ingredient.name.contains("salatalık") {
                return "Sebze & Meyve"
            } else {
                return "Diğer"
            }
        }
    }
    
    init() {
        loadShoppingItems()
    }
    
    func loadShoppingItems() {
        shoppingItems = [
            ShoppingItem(id: UUID(), ingredient: Ingredient(id: UUID(), name: "Kıyma"), amount: 500, unit: "gr", userId: nil),
            ShoppingItem(id: UUID(), ingredient: Ingredient(id: UUID(), name: "Soğan"), amount: 2, unit: "adet", userId: nil),
            ShoppingItem(id: UUID(), ingredient: Ingredient(id: UUID(), name: "Domates"), amount: 3, unit: "adet", userId: nil),
            ShoppingItem(id: UUID(), ingredient: Ingredient(id: UUID(), name: "Un"), amount: 250, unit: "gr", userId: nil),
            ShoppingItem(id: UUID(), ingredient: Ingredient(id: UUID(), name: "Süt"), amount: 1, unit: "litre", userId: nil)
        ]
    }
    
    func toggleItemCheck(_ item: ShoppingItem) {
        if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
            shoppingItems[index].isChecked.toggle()
            // save really checked items to UserDefaults or API
        }
    }
    
    func removeItems(at offsets: IndexSet, category: String) {
        let itemsInCategory = groupedItems[category] ?? []
        let itemsToRemove = offsets.map { itemsInCategory[$0] }
        
        for item in itemsToRemove {
            if let index = shoppingItems.firstIndex(where: { $0.id == item.id }) {
                shoppingItems.remove(at: index)
            }
        }
        
        // save deleted items
    }
    
    func clearCheckedItems() {
        shoppingItems.removeAll(where: { $0.isChecked })
        // save really checked items to UserDefaults or API
    }
    
    func clearAllItems() {
        showingClearAlert = true
    }
    
    func confirmClearAllItems() {
        shoppingItems.removeAll()
        // save cleared items to UserDefaults or API
    }
    
    func sortItems() {
        shoppingItems.sort { $0.ingredient.name < $1.ingredient.name }
    }
    
    func generateShoppingListText() -> String {
        var text = "Recipe Buddy - Alışveriş Listesi\n\n"
        for (category, items) in groupedItems {
            text += "--- \(category) ---\n"
            for item in items {
                text += "• \(item.ingredient.name): \(String(format: "%.1f", item.amount)) \(item.unit)\n"
            }
            text += "\n"
        }
        return text
    }
}
