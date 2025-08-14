import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: UUID
    let fullName: String?
    let email: String
    let username: String?
    let avatarUrl: String?
    let totalRatingPoints: Int?
    let totalRatingsReceived: Int?

    enum CodingKeys: String, CodingKey {
        case id, username, email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case totalRatingPoints = "total_rating_points"
        case totalRatingsReceived = "total_ratings_received"
    }
}
