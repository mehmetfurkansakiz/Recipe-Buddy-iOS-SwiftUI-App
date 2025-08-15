import SwiftUI

struct RecipeInfoBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .foregroundStyle(color)
                .frame(width: 18, height: 18)
            Text(text)
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(Color("A3A3A3"))
        }
        .lineLimit(1)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color("F2F2F7"))
        .cornerRadius(8)
    }
}
