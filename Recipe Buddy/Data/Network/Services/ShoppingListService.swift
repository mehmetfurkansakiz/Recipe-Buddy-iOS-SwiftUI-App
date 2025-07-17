import Foundation
import Supabase

@MainActor
class ShoppingListService {
    static let shared = ShoppingListService()
    private init() {}
    
    private let supabase = SupabaseClient(supabaseURL: Secrets.supabaseURL, supabaseKey: Secrets.supabaseKey)
    
    /// Mevcut kullanıcının tüm alışveriş listelerini çeker.
    func fetchUserShoppingLists() async throws -> [ShoppingList] {
        guard let userId = try? await supabase.auth.session.user.id else { throw URLError(.userAuthenticationRequired) }
        
        let lists: [ShoppingList] = try await supabase.from("shopping_lists")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        return lists
    }
    
    /// Verilen isimle yeni bir alışveriş listesi oluşturur ve oluşturulan listeyi geri döndürür.
    func createNewList(withName name: String) async throws -> ShoppingList {
        guard let userId = try? await supabase.auth.session.user.id else { throw URLError(.userAuthenticationRequired) }
        
        let newList: ShoppingList = try await supabase.from("shopping_lists")
            .insert(["name": name, "user_id": userId.uuidString])
            .select()
            .single()
            .execute()
            .value
        return newList
    }
    
    /// Seçilen malzemeleri, belirtilen bir listeye akıllı bir şekilde ekler
    func addIngredients(_ ingredients: [RecipeIngredientJoin], to list: ShoppingList) async throws {
        for recipeIngredient in ingredients {
            // Bu malzeme listede zaten var mı diye kontrol et
            let existingItems: [ShoppingListItem] = try await supabase.from("shopping_list_items")
                .select("id, amount")
                .eq("list_id", value: list.id)
                .eq("ingredient_id", value: recipeIngredient.ingredient.id)
                .eq("unit", value: recipeIngredient.unit)
                .execute()
                .value

            if let existingItem = existingItems.first {
                // VARSA: Miktarı artır (UPDATE)
                let newAmount = existingItem.amount + recipeIngredient.amount
                try await supabase.from("shopping_list_items")
                    .update(["amount": newAmount])
                    .eq("id", value: existingItem.id)
                    .execute()
            } else {
                // YOKSA: Yeni bir satır olarak ekle (INSERT)
                try await supabase.from("shopping_list_items")
                    .insert(ShoppingListItemInsert(from: recipeIngredient, listId: list.id))
                    .execute()
            }
        }
    }
}
