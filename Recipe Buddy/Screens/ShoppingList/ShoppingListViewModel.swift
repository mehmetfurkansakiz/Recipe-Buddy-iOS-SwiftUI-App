import Foundation
import Supabase
import Combine

@MainActor
class ShoppingListViewModel: ObservableObject {
    @Published var shoppingLists: [ShoppingList] = []
    @Published var itemsByListID: [UUID: [ShoppingListItem]] = [:]
    @Published var isLoading = false
    @Published var expandedListID: UUID?
    @Published var showingClearAlertForList: ShoppingList?
    
    /// Herhangi bir listede işaretlenmiş öğe olup olmadığını kontrol eder.
    func hasCheckedItems(in listId: UUID) -> Bool {
        itemsByListID[listId]?.contains { $0.isChecked } ?? false
    }
    
    func areAllItemsChecked(in list: ShoppingList) -> Bool {
        guard let items = itemsByListID[list.id], !items.isEmpty else { return false }
        return items.allSatisfy { $0.isChecked }
    }
    
    // MARK: - Initialization
    
    init() {}
    
    // init for preview
    init(forPreview: Bool) {
        if forPreview {
            self.shoppingLists = ShoppingList.mockLists
            for list in self.shoppingLists {
                self.itemsByListID[list.id] = ShoppingListItem.mocks(for: list)
            }
            self.expandedListID = self.shoppingLists.first?.id
            self.isLoading = false
        }
    }
    
    /// get all shopping lists from the database
    func fetchAllLists() async {
        isLoading = true
        defer { isLoading = false }
        
        guard (try? await supabase.auth.session.user.id) != nil else { return }
        
        do {
            let lists: [ShoppingList] = try await supabase
                .rpc("get_shopping_lists_with_counts")
                .execute()
                .value
            
            self.shoppingLists = lists
        } catch {
            print("❌ Error fetching lists via RPC: \(error)")
        }
    }
    
    private func fetchItems(for listId: UUID) async {
        // if items are already fetched for this list, do nothing
        guard itemsByListID[listId] == nil else { return }
        
        do {
            let response: [ShoppingListItem] = try await supabase.from("shopping_list_items")
                .select("*, ingredient:ingredients(id, name)")
                .eq("list_id", value: listId)
                .order("is_checked", ascending: true)
                .order("created_at", ascending: true)
                .execute()
                .value
            itemsByListID[listId] = response
        } catch {
            print("❌ Error fetching items for list \(listId): \(error)")
        }
    }
    
    // MARK: - List & Item Management
    
    /// get items to show or hide the list
    func toggleListExpansion(listId: UUID) async {
        let newExpandedID = (expandedListID == listId) ? nil : listId

        self.expandedListID = newExpandedID
        
        if let idToFetch = newExpandedID {
            await fetchItems(for: idToFetch)
        }
    }
    
    /// update toggle item check state in the database
    func toggleItemCheck(_ item: ShoppingListItem) async {
        guard let listId = findListID(for: item) else { return }
        
        if let itemIndex = itemsByListID[listId]?.firstIndex(where: { $0.id == item.id }) {
            itemsByListID[listId]?[itemIndex].isChecked.toggle()
        }
        
        do {
            try await supabase.from("shopping_list_items")
                .update(["is_checked": !item.isChecked])
                .eq("id", value: item.id)
                .execute()
        } catch {
            print("❌ Error toggling item: \(error)")
            if let itemIndex = itemsByListID[listId]?.firstIndex(where: { $0.id == item.id }) {
                itemsByListID[listId]?[itemIndex].isChecked.toggle()
            }
        }
    }
    
    /// delete checked items from the database
    func clearCheckedItems(in list: ShoppingList) async {
        let checkedItemIds = (itemsByListID[list.id] ?? []).filter { $0.isChecked }.map { $0.id }
        guard !checkedItemIds.isEmpty else { return }
        
        do {
            try await supabase.from("shopping_list_items")
                .delete()
                .in("id", values: checkedItemIds)
                .execute()
            
            itemsByListID[list.id]?.removeAll { $0.isChecked }
            
            if itemsByListID[list.id]?.isEmpty ?? false {
                await deleteList(list)
            }
            
        } catch {
            print("❌ Error clearing checked items: \(error)")
        }
    }
    
    /// delete all list items from the database
    func clearAllItems(in list: ShoppingList) {
        showingClearAlertForList = list
    }
    
    /// confirm clearing all items in the list
    func confirmClearAllItems() async {
        guard let listToClear = showingClearAlertForList else { return }
        defer { showingClearAlertForList = nil }
        
        await deleteList(listToClear)
    }
    
    /// delete a shopping list and its items from the database
    func deleteList(_ list: ShoppingList) async {
        do {
            try await supabase.from("shopping_list_items")
                .delete()
                .eq("list_id", value: list.id)
                .execute()
            
            try await supabase.from("shopping_lists")
                .delete()
                .eq("id", value: list.id)
                .execute()
            
            shoppingLists.removeAll { $0.id == list.id }
            itemsByListID.removeValue(forKey: list.id)
            
        } catch {
            print("❌ Error deleting list \(list.id): \(error)")
        }
    }

    /// Creates a new shopping list.
    func createNewList(withName name: String) async {
        guard let userId = try? await supabase.auth.session.user.id else { return }
        
        do {
            let newList: ShoppingList = try await supabase.from("shopping_lists")
                .insert(["name": name, "user_id": userId.uuidString])
                .select()
                .single()
                .execute()
                .value
            
            shoppingLists.insert(newList, at: 0) // add list to the top
        } catch {
            print("❌ Error creating new list: \(error)")
        }
    }

    // MARK: - Helpers
    
    /// Finds which list an item belongs to.
    private func findListID(for item: ShoppingListItem) -> UUID? {
        for (listId, items) in itemsByListID {
            if items.contains(where: { $0.id == item.id }) {
                return listId
            }
        }
        return nil
    }
}

// MARK: - Mock Data for Previews
extension ShoppingListViewModel {
    
    /// An example of a filled, dummy ViewModel used for previews.
    static var mock: ShoppingListViewModel {
        let vm = ShoppingListViewModel()
        
        let mockLists = ShoppingList.mockLists
        vm.shoppingLists = mockLists
        
        for list in mockLists {
            vm.itemsByListID[list.id] = ShoppingListItem.mocks(for: list)
        }
        
        if let firstList = mockLists.first {
            vm.expandedListID = firstList.id
        }
        
        vm.isLoading = false
        
        return vm
    }
}
