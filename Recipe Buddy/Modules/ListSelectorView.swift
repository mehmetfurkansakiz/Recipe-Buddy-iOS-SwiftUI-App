import SwiftUI

struct ListSelectorView: View {
    var onListSelected: (ShoppingList) async -> Void
    var onCancel: () -> Void
    
    @State private var lists: [ShoppingList] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if lists.isEmpty {
                    Text("Hiç alışveriş listeniz yok.")
                        .foregroundStyle(.secondary)
                } else {
                    listBody
                }
            }
            .navigationTitle("Listeye Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal", action: onCancel)
                }
            }
            .task {
                await fetchLists()
            }
        }
    }
    
    private var listBody: some View {
        List {
            // TODO: Yeni liste oluşturma butonu için de bir closure eklenmeli.
            
            ForEach(lists) { list in
                Button(action: {
                    Task {
                        await onListSelected(list)
                    }
                }) {
                    HStack {
                        Image(systemName: "checklist")
                        Text(list.name)
                        Spacer()
                        Text("\(list.itemCount) adet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.primary)
            }
        }
    }
    
    private func fetchLists() async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.lists = try await ShoppingListService.shared.fetchListsWithCounts()
        } catch {
            print("❌ Error fetching lists for selector: \(error.localizedDescription)")
            self.lists = []
        }
    }
}

