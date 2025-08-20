import Foundation

// Get full URL for user's avatar image
extension User {    
    func avatarPublicURL(width: Int = 120) -> URL? {
        guard let avatarPath = avatarUrl, !avatarPath.isEmpty else { return nil }
        
        let cloudfrontDomain = Secrets.cloudfrontDomain
        var urlString = "\(cloudfrontDomain)/\(avatarPath)"
        urlString += "?w=\(width)&q=80"
        
        return URL(string: urlString)
    }
}
