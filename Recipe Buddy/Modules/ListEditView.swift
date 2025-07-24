import SwiftUI

struct ListEditView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    var onSave: () -> Void
    var onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    listNameSection
                    itemsSection
                }
                .padding()
            }
            
            Spacer()
            
            saveButtonView
                .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    /// The header view with title and close button.
    private var headerView: some View {
        HStack {
            Text(viewModel.listToEdit != nil ? "Listeyi Düzenle" : "Yeni Liste Oluştur")
                .font(.headline).fontWeight(.bold)
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2).foregroundStyle(.secondary.opacity(0.5))
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    /// The section for entering the list name.
    private var listNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LİSTE ADI")
                .font(.caption).foregroundStyle(.secondary)
            
            TextField("Örn: Haftalık Alışveriş", text: $viewModel.listNameForSheet)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(10)
        }
    }
    
    /// The section for managing ingredients.
    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MALZEMELER")
                .font(.caption).foregroundStyle(.secondary)
            
            // List of existing/added items
            VStack {
                if viewModel.itemsForEditingList.isEmpty {
                    Text("Henüz malzeme eklenmedi.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 60)
                } else {
                    ForEach($viewModel.itemsForEditingList) { $item in
                        EditableShoppingItemRow(item: $item) {
                            // Find the index and remove it
                            if let index = viewModel.itemsForEditingList.firstIndex(where: { $0.id == item.id }) {
                                viewModel.itemsForEditingList.remove(at: index)
                            }
                        }
                    }
                }
            }
            
            // Input for adding a new item
            HStack {
                TextField("Yeni Malzeme Ekle", text: $viewModel.newItemName)
                    .focused($isTextFieldFocused)
                Button("Ekle", action: viewModel.addItemToEditor)
                    .disabled(viewModel.newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(10)
        }
    }
    
    /// The main save button.
    private var saveButtonView: some View {
        Button(action: onSave) {
            Text(viewModel.listToEdit != nil ? "Değişiklikleri Kaydet" : "Listeyi Oluştur")
                .fontWeight(.semibold).frame(maxWidth: .infinity).padding()
                .background(Color("EBA72B")).foregroundStyle(.white).cornerRadius(12)
        }
        .disabled(viewModel.listNameForSheet.trimmingCharacters(in: .whitespaces).isEmpty)
        .opacity(viewModel.listNameForSheet.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
    }
}

#Preview {
    ListEditView(viewModel: ShoppingListViewModel(), onSave: {}, onCancel: {})
}
