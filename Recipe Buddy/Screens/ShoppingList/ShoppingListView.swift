import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            Color("FBFBFB").ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.shoppingLists.isEmpty {
                EmptyShoppingListView()
                // TODO: Yeni liste oluşturma alert/sheet'ini göster
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.shoppingLists) { list in
                            ShoppingListSectionView(
                                list: list,
                                items: viewModel.itemsByListID[list.id] ?? [],
                                isExpanded: viewModel.expandedListID == list.id,
                                onHeaderTap: {
                                    Task { await viewModel.toggleListExpansion(listId: list.id) }
                                },
                                onItemToggle: { item in
                                    Task { await viewModel.toggleItemCheck(item) }
                                },
                                onClearChecked: {
                                    Task { await viewModel.clearCheckedItems(in: list) }
                                },
                                onClearAll: {
                                    viewModel.clearAllItems(in: list)
                                }
                            )
                            Divider().padding(.leading, 50)
                        }
                    }
                }
            }
        }
        .navigationTitle("Alışveriş Listelerim")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { /* TODO: Yeni liste ekleme popup'ını göster */ }) {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.fetchAllLists()
        }
        .alert(
            "Listeyi Temizle",
            isPresented: Binding(
                get: { viewModel.showingClearAlertForList != nil },
                set: { if !$0 { viewModel.showingClearAlertForList = nil } }
            ),
            actions: {
                Button("Temizle", role: .destructive) {
                    Task { await viewModel.confirmClearAllItems() }
                }
                Button("İptal", role: .cancel) {}
            },
            message: {
                Text("'\((viewModel.showingClearAlertForList?.name) ?? "")' listesindeki tüm öğeler silinecek. Emin misiniz?")
            }
        )    }
}


// MARK: - Helper Views

/// show a list of shopping lists
struct ShoppingListSectionView: View {
    let list: ShoppingList
    let items: [ShoppingListItem]
    let isExpanded: Bool
    let onHeaderTap: () -> Void
    let onItemToggle: (ShoppingListItem) -> Void
    let onClearChecked: () -> Void
    let onClearAll: () -> Void
    
    private var areAllItemsChecked: Bool { !items.isEmpty && items.allSatisfy { $0.isChecked } }
    private var hasCheckedItems: Bool { items.contains { $0.isChecked }}
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            if isExpanded {
                ForEach(items) { item in
                    ShoppingItemRow(item: item, onToggle: { onItemToggle(item) })
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Image(systemName: areAllItemsChecked ? "checklist.checked" : "checklist")
                .font(.title2).foregroundStyle(areAllItemsChecked ? .gray : Color("EBA72B"))
            
            Text(list.name)
                .font(.headline).strikethrough(areAllItemsChecked, color: .gray)
                .foregroundStyle(areAllItemsChecked ? .gray : Color("EBA72B"))
            
            Spacer()
            
            Menu {
                Button("İşaretlileri Temizle", action: onClearChecked).disabled(!hasCheckedItems)
                Button("Tüm Listeyi Temizle", role: .destructive, action: onClearAll)
            } label: {
                Image(systemName: "ellipsis.circle").font(.title2)
            }
            .tint(.secondary)
            
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.001))
        .contentShape(Rectangle())
        .onTapGesture(perform: onHeaderTap)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
}

// MARK: - Preview
#Preview {
    ShoppingListView(navigationPath: .constant(NavigationPath()))
}

#Preview("Dolu Alışveriş Listesi") {
    NavigationStack {
        ShoppingListView(navigationPath: .constant(NavigationPath()))
    }
}
