//
//  ShoppingListView.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
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
                    .listStyle(InsetGroupedListStyle())
                    
                    VStack(spacing: 8) {
                        Button(action: {
                            viewModel.clearCheckedItems()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Seçili Öğeleri Temizle")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.FF_2_A_1_F).opacity(0.8))
                            .foregroundStyle(.FFFFFF)
                            .cornerRadius(8)
                        }
                        .disabled(!viewModel.hasCheckedItems)
                        .opacity(viewModel.hasCheckedItems ? 1 : 0.6)
                        
                        Button(action: {
                            viewModel.showingShareSheet = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Listeyi Paylaş")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(._33_C_759))
                            .foregroundStyle(.FFFFFF)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Alışveriş Listesi")
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Kapat")
                        .foregroundStyle(.EBA_72_B)
                },
                trailing: Menu {
                    Button(action: {
                        viewModel.clearAllItems()
                    }) {
                        Label("Tüm Listeyi Temizle", systemImage: "trash")
                    }
                    
                    Button(action: {
                        viewModel.sortItems()
                    }) {
                        Label("Alfabetik Sırala", systemImage: "arrow.up.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.EBA_72_B)
                }
            )
            .sheet(isPresented: $viewModel.showingShareSheet) {
                ShareSheet(items: [viewModel.generateShoppingListText()])
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
}

#Preview {
    let viewModel = ShoppingListViewModel()
    return ShoppingListView(viewModel: viewModel)
}
