import SwiftUI
import NukeUI

struct ExploreRecipeCard: View {
    let recipe: Recipe
    let cardWidth: CGFloat
    
    private var badgeWidth: CGFloat  {
        let threshold: CGFloat = 150
        if cardWidth < threshold {
            return cardWidth * 0.4
        } else {
            return (threshold * 0.40) + (cardWidth - threshold) * 0.10
        }
    }
    
    private var iconSize: CGFloat { max(12, cardWidth / 16) } // minimum 12
    private var fontSize: Font { .system(size: max(12, cardWidth / 18), weight: .regular) } // minimum 12
    private var verticalPadding: CGFloat { max(4, cardWidth / 35) } // minimum 4
    private var cornerRadius: CGFloat { max(8, cardWidth / 12) } // minimum 8

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // main container
            ZStack(alignment: .bottom) {
                
                // Image
                LazyImage(url: recipe.imagePublicURL()) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        ZStack {
                            Color("F2F2F7")
                                .overlay {
                                    Image(systemName: "photo")
                                        .foregroundStyle(Color.C_2_C_2_C_2)
                                        .font(.largeTitle)
                                }
                        }
                    }
                }
                .frame(width: cardWidth, height: cardWidth)
                
                // Badges
                HStack(spacing: 0) {
                    // left badge for time
                    HStack(spacing: 4) {
                        Image("alarm.icon")
                            .resizable()
                            .frame(width: iconSize, height: iconSize)
                        Text("\(recipe.cookingTime) dk")
                    }
                    .font(fontSize)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.vertical, verticalPadding)
                    .frame(width: badgeWidth)
                    .padding(.horizontal, 8)
                    .background(.black.opacity(0.5))
                    .clipShape(CornerBadgeShape(radius: cardWidth / 12, corners: [.topRight, .bottomRight]))
                    
                    Spacer()
                    
                    // right badge for star point
                    if let rating = recipe.rating, rating > 0 {
                        HStack(spacing: 4) {
                            Image("star.fill.icon")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                            Text(String(format: "%.1f", rating))
                        }
                        .font(fontSize)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.vertical, verticalPadding)
                        .frame(width: badgeWidth)
                        .padding(.horizontal, 8)
                        .background(.black.opacity(0.5))
                        .clipShape(CornerBadgeShape(radius: cornerRadius, corners: [.topLeft, .bottomLeft]))
                    } else {
                        HStack(spacing: 4) {
                            Image("star.icon")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                            Text("0.0 (\(recipe.ratingCount ?? 0))")
                        }
                        .font(fontSize)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.vertical, verticalPadding)
                        .frame(width: badgeWidth)
                        .padding(.horizontal, 8)
                        .background(.black.opacity(0.5))
                        .clipShape(CornerBadgeShape(radius: cornerRadius, corners: [.topLeft, .bottomLeft]))
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
    var radius: CGFloat = 12
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
