//
//  ShoppingListManager.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import Foundation

class ShoppingListManager {
    static let shared = ShoppingListManager()
    
    private init() {}
    
    @Published var shoppingItems: [ShoppingItem] = []
    
    func addItems(_ items: [ShoppingItem]) {
        for item in items {
            if let index = shoppingItems.firstIndex(where: {
                $0.ingredient.name == item.ingredient.name && $0.unit == item.unit
            }) {
                // if have same item name and unit, increase amount
                let newAmount = shoppingItems[index].amount + item.amount
                shoppingItems[index].amount = newAmount
            } else {
                shoppingItems.append(item)
            }
        }
    }
    
    func removeItem(at index: Int) {
        shoppingItems.remove(at: index)
    }
    
    func toggleItemCheck(at index: Int) {
        shoppingItems[index].isChecked.toggle()
    }
    
    func clearCheckedItems() {
        shoppingItems.removeAll(where: { $0.isChecked })
    }
    
    func clearAllItems() {
        shoppingItems.removeAll()
    }
}
