import SwiftUI
import NukeUI

struct ExploreRecipeCard: View {
    let recipe: Recipe
    let cardWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // main container
            ZStack(alignment: .bottom) {
                
                // Image
                LazyImage(url: recipe.imagePublicURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            Color("F2F2F7")
                            ProgressView()
                        }
                    }
                }
                .frame(width: cardWidth, height: cardWidth)
                
                // Badges
                HStack {
                    // left badge for time
                    HStack(spacing: 4) {
                        Image("alarm.icon")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text("\(recipe.cookingTime) dk")
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.5))
                    .clipShape(CornerBadgeShape(corners: [.topRight, .bottomRight]))
                    
                    Spacer()
                    
                    // right badge for star point
                    if let rating = recipe.rating, rating > 0 {
                        HStack(spacing: 4) {
                            Image("star.fill.icon")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text(String(format: "%.1f", rating))
                        }
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.5))
                        .clipShape(CornerBadgeShape(corners: [.topLeft, .bottomLeft]))
                    }
                }
                .foregroundColor(Color("FFFFFF"))
                .fontWeight(.heavy)
            }
            .frame(width: cardWidth, height: cardWidth)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundStyle(Color("181818"))
                    .lineLimit(1)
                
                Text(recipe.user?.fullName ?? "Anonim")
                    .font(.caption)
                    .foregroundStyle(Color("303030"))
                    .lineLimit(1)
            }
        }
        .frame(width: cardWidth)
    }
}

struct CornerBadgeShape: Shape {
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 12, height: 12)
        )
        return Path(path.cgPath)
    }
}
