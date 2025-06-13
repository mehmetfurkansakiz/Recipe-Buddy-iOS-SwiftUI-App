import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    let width: CGFloat
    private var imageURL: URL? {
        let baseSupabaseURL = Secrets.supabaseURL.deletingLastPathComponent().absoluteString.replacingOccurrences(of: "/rest/v1", with: "")

        let urlString = "\(baseSupabaseURL)/storage/v1/object/public/recipe-images/\(recipe.imageName)"
        return URL(string: urlString)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    ZStack {
                        Color.gray.opacity(0.2)
                        Image(systemName: "photo.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                case .empty:
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: width - 16, height: width * 1)
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
                
                if let rating = recipe.rating {
                    Image("star.fill.icon")
                        .foregroundStyle(Color("FFCB1F"))
                    Text(String(format: "%.1f", rating))
                        .font(.caption)
                        .foregroundStyle(Color("A3A3A3"))
                } else {
                    Image("star.icon")
                        .foregroundStyle(Color("C2C2C2"))
                }
            }
        }
        .padding(8)
        .background(Color("FBFBFB"))
        .cornerRadius(8)
        .shadow(radius: 1)
        .padding(.vertical, 8)
    }
}
