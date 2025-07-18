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
            } else {
                listContent
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Alışveriş Listelerim")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("EBA72B"))
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Text("Liste Oluştur")
                        .font(.headline)
                        .fontWeight(.bold)
                    Image("plus.icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                .onTapGesture(perform: {
                    /* TODO: Yeni liste ekleme */
                })
                .foregroundStyle(Color("EBA72B"))
            }
        }
        .task {
            await viewModel.fetchAllLists()
        }
    }
    
    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: []) {
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
                        onListDelete: {
                            Task { await viewModel.deleteList(list) }
                        }
                    )
                }
            }
            .padding(.top)
        }
    }
}


// MARK: - Helper Views

/// show a list of shopping lists
struct ShoppingListSectionView: View {
    let list: ShoppingList
    let items: [ShoppingListItem]
    let isExpanded: Bool
    let onHeaderTap: () -> Void
    let onItemToggle: (ShoppingListItem) -> Void
    let onListDelete: () -> Void
    
    private var areAllItemsChecked: Bool { !items.isEmpty && items.allSatisfy(\.isChecked) }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            if isExpanded {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    ShoppingItemRowView(item: item, index: index) {
                        onItemToggle(item)
                    }
                    // TODO: itemlar için de basılı tutma ve düzenleme gibi özellikler
                }
                .padding(.horizontal, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
    
    private var header: some View {
        HStack {
            Text(list.name)
                .font(.title3)
                .fontWeight(.bold)
            
            Circle()
                .frame(width: 4, height: 4)
                .foregroundStyle(.secondary)
                .opacity(0.5)
            
            Text("\(list.itemCount) adet")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture(perform: onHeaderTap)
        .contextMenu {
            Button {
                // TODO: ViewModel'da düzenleme fonksiyonunu çağır
            } label: {
                Label("Listeyi Düzenle", systemImage: "pencil")
            }
            
            Button {
                // TODO: ViewModel'da tümünü işaretleme fonksiyonunu çağır
            } label: {
                Label("Tümünü İşaretle", systemImage: "checklist")
            }
            
            Divider()
            
            Button(role: .destructive, action: onListDelete) {
                Label("Listeyi Sil", systemImage: "trash")
            }
        }
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
