import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("A3A3A3"))
            
            TextField("Tarif Ara...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundColor(Color("181818"))
                .tint(Color("EBA72B"))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image("close.circle.icon")
                        .resizable()
                        .foregroundStyle(Color("A3A3A3"))
                        .frame(width: 18, height: 18)
                }
            }
        }
        .frame(height: 40)
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color("F2F2F7"))
        .cornerRadius(8)
        
    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
}
