import SwiftUI

struct ShoppingListView: View {
    @StateObject var viewModel: ShoppingListViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
            VStack {
                if viewModel.shoppingItems.isEmpty {
                    EmptyShoppingListView()
                } else {
                    List {
                        ForEach(viewModel.groupedItems.keys.sorted(), id: \.self) { category in
                            Section(header: Text(category)) {
                                ForEach(viewModel.groupedItems[category] ?? []) { item in
                                    ShoppingItemRow(
                                        item: item,
                                        onToggle: {
                                            viewModel.toggleItemCheck(item)
                                        }
                                    )
                                }
                                .onDelete { indexSet in
                                    viewModel.removeItems(at: indexSet, category: category)
                                }
                            }
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Button(action: {
                            viewModel.clearCheckedItems()
                        }) {
                            HStack {
                                Image("trash.icon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("Seçili Öğeleri Temizle")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("FF2A1F").opacity(0.8))
                            .foregroundStyle(Color("FFFFFF"))
                            .cornerRadius(8)
                        }
                        .disabled(!viewModel.hasCheckedItems)
                        .opacity(viewModel.hasCheckedItems ? 1.0 : 0.6)
                        
                        ShareLink(item: viewModel.generateShoppingListText(),
                                  subject: Text("Alışveriş Listesi"),
                                  message: Text(viewModel.generateShoppingListText())) {
                            HStack {
                                Image("share.icon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("Listeyi Paylaş")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("33C759"))
                            .foregroundStyle(Color("FFFFFF"))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Alışveriş Sepetim")
                        .foregroundStyle(Color("EBA72B"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.clearAllItems()
                        }) {
                            HStack {
                                Text("Tüm Listeyi Temizle")
                                Image("trash.icon")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                            }
                        }
                        
                        Button(action: {
                            viewModel.sortItems()
                        }) {
                            HStack {
                                Text("Alfabetik Sırala")
                                Image("arrow.up.down.icon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                    } label: {
                        Image("more.horizontal.icon")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color("EBA72B"))
                    }
                }
            }
            .alert(isPresented: $viewModel.showingClearAlert) {
                Alert(
                    title: Text("Listeyi Temizle"),
                    message: Text("Tüm alışveriş listesi temizlenecek. Emin misiniz?"),
                    primaryButton: .destructive(Text("Temizle")) {
                        viewModel.confirmClearAllItems()
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}

#Preview {
    ShoppingListView(viewModel: ShoppingListViewModel(), navigationPath: .constant(NavigationPath()))
}
