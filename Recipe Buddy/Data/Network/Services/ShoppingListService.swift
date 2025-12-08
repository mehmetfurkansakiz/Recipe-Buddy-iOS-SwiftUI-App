import Foundation
import Supabase

@MainActor
class ShoppingListService {
    static let shared = ShoppingListService()
    
    /// Fetches all of the current user's lists along with their item counts via an RPC.
    func fetchListsWithCounts() async throws -> [ShoppingList] {
        let lists: [ShoppingList] = try await supabase
            .rpc("get_shopping_lists_with_counts")
            .execute()
            .value
        return lists
    }
    
    /// Fetches all items for a specific shopping list.
    func fetchItems(for listId: UUID) async throws -> [ShoppingListItem] {
        let response: [ShoppingListItem] = try await supabase.from("shopping_list_items")
            .select("*")
            .eq("list_id", value: listId)
            .order("is_checked", ascending: true)
            .order("created_at", ascending: true)
            .execute()
            .value
        return response
    }
    
    /// Creates a new shopping list and returns the created list's UUID.
    func createList(withName name: String) async throws -> UUID {
        guard let userId = try? await supabase.auth.session.user.id else {
            throw URLError(.userAuthenticationRequired)
        }
        
        struct NewListID: Codable {
            let id: UUID
        }
        
        let result: NewListID = try await supabase
            .from("shopping_lists")
            .insert(["name": name, "user_id": userId.uuidString])
            .select("id")
            .single()
            .execute()
            .value
            
        return result.id
    }
    
    /// Updates the name of a specified shopping list.
    func updateList(_ list: ShoppingList, newName: String) async throws {
        try await supabase.from("shopping_lists")
            .update(["name": newName])
            .eq("id", value: list.id)
            .execute()
    }
    
    /// Updates the 'is_checked' status of a single shopping list item.
    func updateItemCheck(id: UUID, isChecked: Bool) async throws {
        try await supabase.from("shopping_list_items")
            .update(["is_checked": isChecked])
            .eq("id", value: id)
            .execute()
    }
    
    /// Updates the 'is_checked' status for all items in a given list.
    func updateCheckStatusForAllItems(listId: UUID, isChecked: Bool) async throws {
        try await supabase.from("shopping_list_items")
            .update(["is_checked": isChecked])
            .eq("list_id", value: listId)
            .execute()
    }
    
    /// Deletes a list and all of its associated items from the database.
    func deleteList(_ list: ShoppingList) async throws {
        
        // 1. Delete all items associated with the list.
        try await supabase.from("shopping_list_items")
            .delete()
            .eq("list_id", value: list.id)
            .execute()
            
        // 2. Delete the list itself.
        try await supabase.from("shopping_lists")
            .delete()
            .eq("id", value: list.id)
            .execute()
    }
    
    /// Deletes all checked items in a given list.
    func clearCheckedItems(in list: ShoppingList, itemIds: [UUID]) async throws {
        try await supabase.from("shopping_list_items")
            .delete()
            .in("id", values: itemIds)
            .execute()
    }
    
    /// Adds an array of recipe ingredients to a shopping list.
    func addRecipeIngredients(_ ingredients: [RecipeIngredientJoin], to list: ShoppingList) async throws {
        let itemsToInsert = ingredients.map {
            ShoppingListItemInsert(
                listId: list.id,
                name: $0.name,
                amount: $0.amount,
                unit: $0.unit,
                ingredientId: $0.ingredientId
            )
        }
        
        if !itemsToInsert.isEmpty {
            try await supabase.from("shopping_list_items").insert(itemsToInsert).execute()
        }
    }
    
    /// add ingredients to a shopping list
    func addIngredients(_ ingredients: [RecipeIngredientJoin], to list: ShoppingList) async throws {
        for recipeIngredient in ingredients {
            
            var query = supabase.from("shopping_list_items")
                .select("*")
                .eq("list_id", value: list.id)
                .eq("unit", value: recipeIngredient.unit)
            
            if let ingredientId = recipeIngredient.ingredientId {
                query = query.eq("ingredient_id", value: ingredientId)
            } else {
                query = query.filter("ingredient_id", operator: "is", value: "null")
                query = query.eq("name", value: recipeIngredient.name)
            }
            
            let existingItems: [ShoppingListItem] = try await query.execute().value

            if let existingItem = existingItems.first {
                // if existing item found, update the amount
                let newAmount = existingItem.amount + recipeIngredient.amount
                try await supabase.from("shopping_list_items")
                    .update(["amount": newAmount])
                    .eq("id", value: existingItem.id)
                    .execute()
            } else {
                // if does not exist, insert a new item
                try await supabase.from("shopping_list_items")
                    .insert(ShoppingListItemInsert(from: recipeIngredient, listId: list.id))
                    .execute()
            }
        }
    }
    
    /// Deletes all items for a given list ID and inserts a new set of items.
    func replaceItems(for listId: UUID, with items: [ShoppingListItemInsert]) async throws {
        // 1. Delete all existing items for this list.
        try await supabase.from("shopping_list_items")
            .delete()
            .eq("list_id", value: listId)
            .execute()
            
        // 2. Insert the new list of items, if any.
        if !items.isEmpty {
            try await supabase.from("shopping_list_items").insert(items).execute()
        }
    }

}
