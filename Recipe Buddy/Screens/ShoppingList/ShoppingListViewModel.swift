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
    
    /// Kullanıcının tüm alışveriş listelerini çeker.
    func fetchAllLists() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let userId = try? await supabase.auth.session.user.id else { return }
        
        do {
            let lists: [ShoppingList] = try await supabase.from("shopping_lists")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.shoppingLists = lists
            
            if lists.isEmpty {
                await createNewList(withName: "Genel Alışveriş Listem")
            }
        } catch {
            print("❌ Error fetching shopping lists: \(error)")
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
    
    /// Bir listenin malzemelerini çeker veya gizler (aç/kapa).
    func toggleListExpansion(listId: UUID) async {
        let newExpandedID = (expandedListID == listId) ? nil : listId

        self.expandedListID = newExpandedID
        
        if let idToFetch = newExpandedID {
            await fetchItems(for: idToFetch)
        }
    }
    
    /// Bir malzemenin "alındı" durumunu günceller.
    func toggleItemCheck(_ item: ShoppingListItem) async {
        guard let listId = findListID(for: item) else { return }
        
        // Önce UI'ı anında güncelle (optimistic update)
        if let itemIndex = itemsByListID[listId]?.firstIndex(where: { $0.id == item.id }) {
            itemsByListID[listId]?[itemIndex].isChecked.toggle()
        }
        
        // Sonra veritabanını güncelle
        do {
            try await supabase.from("shopping_list_items")
                .update(["is_checked": !item.isChecked])
                .eq("id", value: item.id)
                .execute()
        } catch {
            print("❌ Error toggling item: \(error)")
            // Hata olursa UI'ı eski haline geri döndür
            if let itemIndex = itemsByListID[listId]?.firstIndex(where: { $0.id == item.id }) {
                itemsByListID[listId]?[itemIndex].isChecked.toggle()
            }
        }
    }
    
    /// İşaretlenmiş öğeleri siler.
    func clearCheckedItems(in list: ShoppingList) async {
        let checkedItemIds = (itemsByListID[list.id] ?? []).filter { $0.isChecked }.map { $0.id }
        guard !checkedItemIds.isEmpty else { return }
        
        do {
            try await supabase.from("shopping_list_items")
                .delete()
                .in("id", values: checkedItemIds)
                .execute()
            
            itemsByListID[list.id]?.removeAll { $0.isChecked }
        } catch {
            print("❌ Error clearing checked items: \(error)")
        }
    }
    
    /// Tüm listeyi temizlemek için onayı başlatır.
    func clearAllItems(in list: ShoppingList) {
        showingClearAlertForList = list
    }
    
    /// Kullanıcı onayladıktan sonra listenin tüm içeriğini temizler.
    func confirmClearAllItems() async {
        guard let listToClear = showingClearAlertForList else { return }
        defer { showingClearAlertForList = nil }
        
        do {
            try await supabase.from("shopping_list_items")
                .delete()
                .eq("list_id", value: listToClear.id)
                .execute()
            
            itemsByListID[listToClear.id]?.removeAll()
        } catch {
            print("❌ Error clearing all items: \(error)")
        }
    }

    /// Yeni bir alışveriş listesi oluşturur.
    func createNewList(withName name: String) async {
        guard let userId = try? await supabase.auth.session.user.id else { return }
        
        do {
            let newList: ShoppingList = try await supabase.from("shopping_lists")
                .insert(["name": name, "user_id": userId.uuidString])
                .select()
                .single()
                .execute()
                .value
            
            shoppingLists.insert(newList, at: 0) // Yeni listeyi en üste ekle
        } catch {
            print("❌ Error creating new list: \(error)")
        }
    }

    // MARK: - Helpers
    
    /// Bir öğenin hangi listeye ait olduğunu bulur.
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
    
    /// Önizlemeler için kullanılan, içi dolu, sahte bir ViewModel örneği.
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
