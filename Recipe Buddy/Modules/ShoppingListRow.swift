import SwiftUI

struct ShoppingItemRow: View {
    let item: ShoppingListItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(item.isChecked ? "checkbox.check.icon" : "checkbox.unchecked.icon")
                    .resizable()
                    .foregroundStyle(item.isChecked ? Color("33C759") : Color("A3A3A3"))
                    .frame(width: 18, height: 18)
            }
            VStack(alignment: .leading) {
                Text(item.name)
                    .bold()
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? Color("A3A3A3") : Color("181818"))
                Text("\(String(format: "%.1f", item.amount)) \(item.unit)")
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? Color("A3A3A3") : Color("303030"))
            }
            
            Spacer()
            
            HStack {
                Button(action: {}) {
                    Image("minus.circle.icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color("A3A3A3"))
                }
                
                Button(action: {}) {
                    Image("plus.circle.icon")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color("A3A3A3"))
                }
            }
        }
    }
}

struct EmptyShoppingListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("cart.icon")
                .resizable()
                .foregroundStyle(Color("A3A3A3"))
                .frame(width: 48, height: 48)
            
            Text("Alışveriş Listeniz Boş")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("181818"))
            
            Text("Tarif detaylarından malzemeleri seçerek alışveriş listenize ekleyebilirsiniz.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("303030"))
                .padding(.horizontal)
        }
    }
}
