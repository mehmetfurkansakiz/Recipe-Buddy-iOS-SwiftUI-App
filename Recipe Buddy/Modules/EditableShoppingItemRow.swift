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
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
            
            TextField("Birim", text: $item.unit)
                .frame(width: 80)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
