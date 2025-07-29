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
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Alışveriş Listelerim")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.EBA_72_B)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Text("Liste Oluştur")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.EBA_72_B)
                    Image("plus.icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.EBA_72_B)
                }
                .onTapGesture(perform: {
                    viewModel.presentListEditSheetForCreate()
                })
            }
        }
        .task {
            await viewModel.fetchAllLists()
        }
        .sheet(isPresented: $viewModel.isShowingEditSheet) {
            ListEditView(
                viewModel: viewModel,
                onSave: {
                    Task { await viewModel.saveList() }
                },
                onCancel: { viewModel.isShowingEditSheet = false }
            )
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
                        },
                        onListEdit: {
                            Task {
                                await viewModel.presentListEditSheetForUpdate(list)
                            }
                        },
                        onToggleCheckAll: {
                            Task {
                                await viewModel.toggleCheckAllItems(in: list)
                            }
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
    // Properties passed from the parent view
    let list: ShoppingList
    let items: [ShoppingListItem]
    let isExpanded: Bool
    
    // Closures for actions
    let onHeaderTap: () -> Void
    let onItemToggle: (ShoppingListItem) -> Void
    let onListDelete: () -> Void
    let onListEdit: () -> Void
    let onToggleCheckAll: () -> Void
    
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

        .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("A3A3A3").opacity(0.5), lineWidth: 1))
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
            Button(action: onListEdit) {
                Label("Listeyi Düzenle", systemImage: "pencil")
            }
            
            Button(action: onToggleCheckAll) {
                Label("Tümünü İşaretle/Kaldır", systemImage: "checklist")
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

#Preview() {
    NavigationStack {
        ShoppingListView(navigationPath: .constant(NavigationPath()))
    }
}
