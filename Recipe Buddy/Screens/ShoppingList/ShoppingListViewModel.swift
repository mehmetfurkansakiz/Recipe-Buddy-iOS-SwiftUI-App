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
    @Published var isShowingEditSheet = false
    @Published var listToEdit: ShoppingList?
    @Published var listNameForSheet = ""
    
    /// A reference to the data service layer.
        private let service = ShoppingListService.shared
    
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
    
    /// Fetches all shopping lists by calling the service layer.
    func fetchAllLists() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.shoppingLists = try await service.fetchListsWithCounts()
        } catch {
            print("❌ Error fetching lists: \(error.localizedDescription)")
        }
    }
    
    /// Fetches the items for a specific list by calling the service.
    private func fetchItems(for listId: UUID) async {
        // This guard prevents re-fetching if data is already loaded.
        guard itemsByListID[listId] == nil else { return }
        
        do {
            let items = try await service.fetchItems(for: listId)
            itemsByListID[listId] = items
        } catch {
            print("❌ Error fetching items for list \(listId): \(error.localizedDescription)")
            // On failure, set an empty array to prevent repeated failed attempts.
            itemsByListID[listId] = []
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
    
    /// Toggles the 'checked' state of an item and calls the service to persist the change.
    func toggleItemCheck(_ item: ShoppingListItem) async {
        guard let listId = findListID(for: item) else { return }
        
        // 1. Optimistically update the UI
        guard let itemIndex = itemsByListID[listId]?.firstIndex(where: { $0.id == item.id }) else { return }
        itemsByListID[listId]?[itemIndex].isChecked.toggle()
        
        // 2. Get the new state to send to the service
        let newCheckedState = itemsByListID[listId]?[itemIndex].isChecked ?? false
        
        // 3. Call the service to update the database
        do {
            try await service.updateItemCheck(id: item.id, isChecked: newCheckedState)
        } catch {
            print("❌ Error toggling item: \(error.localizedDescription)")
            // On failure, revert the UI change
            itemsByListID[listId]?[itemIndex].isChecked.toggle()
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
    
    /// Deletes a shopping list by calling the service layer.
    func deleteList(_ list: ShoppingList) async {
        isLoading = true
        do {
            try await service.deleteList(list)
            // Optimistically update the UI by removing the list locally.
            shoppingLists.removeAll { $0.id == list.id }
        } catch {
            print("❌ Error deleting list: \(error.localizedDescription)")
            // If the deletion fails, refetch from the server to ensure UI is in sync.
            await fetchAllLists()
        }
        isLoading = false
    }
    
    // MARK: - Sheet Presentation
    
    func presentListEditSheetForCreate() {
        listToEdit = nil
        listNameForSheet = ""
        isShowingEditSheet = true
    }
    
    func presentListEditSheetForUpdate(_ list: ShoppingList) {
        listToEdit = list
        listNameForSheet = list.name
        isShowingEditSheet = true
    }
    
    // MARK: - Create / Update Logic
    
    /// Saves changes by calling the appropriate service method.
    func saveList() async {
        let name = listNameForSheet.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        
        isShowingEditSheet = false
        isLoading = true
        
        do {
            if let listToEdit {
                // Edit Mode: Call the update service method.
                try await service.updateList(listToEdit, newName: name)
            } else {
                // Create Mode: Call the create service method.
                try await service.createList(withName: name)
            }
        } catch {
            print("❌ Error saving list: \(error.localizedDescription)")
        }
        
        // Refresh the entire list to show changes.
        await fetchAllLists()
    }

    // MARK: - Helpers
    
    /// Finds which list an item belongs to locally.
    private func findListID(for item: ShoppingListItem) -> UUID? {
        return itemsByListID.first(where: { $0.value.contains(where: { $0.id == item.id }) })?.key
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
