import Foundation

// Get full URL for user's avatar image
extension User {
    var avatarPublicURL: URL? {
        guard let avatarPath = avatarUrl, !avatarPath.isEmpty else { return nil }
        
        let urlString = Secrets.supabaseURL
            .absoluteString.replacingOccurrences(of: "/rest/v1", with: "")
        
        let fullURLString = "\(urlString)/storage/v1/object/public/\(avatarPath)"
        return URL(string: fullURLString)
    }
}
