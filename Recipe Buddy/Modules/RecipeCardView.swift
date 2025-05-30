import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    let width: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(recipe.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: (width - 16), maxWidth: .infinity, minHeight: 150, maxHeight: .infinity)
                .clipped()
                .cornerRadius(8)
            
            Text(recipe.name)
                .font(.headline)
                .lineLimit(1)
                .foregroundStyle(Color("181818"))
            
            HStack(spacing: 8) {
                Image("clock.icon")
                    .resizable()
                    .foregroundStyle(Color("A3A3A3"))
                    .frame(width: 18, height: 18)
                Text("\(recipe.cookingTime) dk")
                    .font(.caption)
                    .foregroundStyle(Color("A3A3A3"))
                
                Spacer()
                
                Image("star.fill.icon")
                    .resizable()
                    .foregroundStyle(Color("FFCB1F"))
                    .frame(width: 18, height: 18)
                Text(String(format: "%.1f", recipe.rating))
                    .font(.caption)
                    .foregroundStyle(Color("A3A3A3"))
            }
        }
        .padding(8)
        .background(Color("FBFBFB"))
        .cornerRadius(8)
        .shadow(radius: 2)
        .frame(minWidth: width, maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
