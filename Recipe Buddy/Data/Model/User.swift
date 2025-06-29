import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: UUID
    let fullName: String?
    let username: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
    }
}
