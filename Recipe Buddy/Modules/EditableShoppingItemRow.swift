import SwiftUI

struct EditableShoppingItemRow: View {
    @Binding var item: EditableShoppingItem
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            TextField("Malzeme Adı", text: $item.name)
            
            Spacer()
            
            TextField("Miktar", text: $item.amount)
                .keyboardType(.decimalPad)
                .frame(width: 50)
                .multilineTextAlignment(.center)
            
            TextField("Birim", text: $item.unit)
                .frame(width: 70)
                .autocapitalization(.none)

            Button(action: {
                withAnimation {
                    onDelete()
                }
            }) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .textFieldStyle(CustomTextFieldStyle())
    }
}
