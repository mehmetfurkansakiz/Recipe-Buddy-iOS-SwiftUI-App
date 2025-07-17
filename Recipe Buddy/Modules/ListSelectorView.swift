import SwiftUI

struct ListSelectorView: View {
    let ingredientsToAdd: [RecipeIngredientJoin]
    let onAddedToList: () -> Void
    
    @State private var lists: [ShoppingList] = []
    @State private var isLoading = true
    @State private var showingAlert = false
    @State private var newListName = ""

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else {
                    List {
                        Button(action: { showingAlert = true }) {
                            Label("Yeni Liste Oluştur", systemImage: "plus.circle.fill")
                        }
                        
                        // Display existing lists
                        ForEach(lists) { list in
                            Button(action: {
                                Task {
                                    await add(to: list)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "checklist")
                                    Text(list.name)
                                    Spacer()
                                }
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Listeye Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                let fetchedList = try? await ShoppingListService.shared.fetchUserShoppingLists()
                self.lists = fetchedList ?? []
                isLoading = false
                
            }
            .alert("Yeni Liste Oluştur", isPresented: $showingAlert) {
                TextField("Liste Adı (Örn: Haftalık Alışveriş)", text: $newListName)
                Button("Oluştur ve Ekle") {
                    Task {
                        if let newList = try? await ShoppingListService.shared.createNewList(withName: newListName) {
                            await add(to: newList)
                        }
                    }
                }
                Button("İptal", role: .cancel) {}
            }
        }
    }
    
    private func add(to list: ShoppingList) async {
        try? await ShoppingListService.shared.addIngredients(ingredientsToAdd, to: list)
        onAddedToList()
    }
}
