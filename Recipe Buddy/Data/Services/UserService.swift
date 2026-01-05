import Foundation
import Supabase

@MainActor
class UserService {
    static let shared = UserService()
    
    /// Fetches the complete profile for the currently logged-in user.
    func fetchCurrentUser() async throws -> User? {
        guard let userId = try? await supabase.auth.session.user.id else {
            // No user is logged in
            return nil
        }
        
        let user: User = try await supabase.from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        return user
    }
    
    /// Updates the current user's profile fields in Supabase. Optionally uploads a new avatar to S3 and stores its key.
    func updateUserProfile(
        fullName: String?,
        city: String?,
        showCity: Bool,
        bio: String?,
        birthDate: Date?,
        showBirthDate: Bool,
        profession: String?,
        avatarImageData: Data?
    ) async throws -> User {
        guard let userId = try? await supabase.auth.session.user.id else {
            throw URLError(.userAuthenticationRequired)
        }

        var avatarKey: String? = nil
        if let data = avatarImageData {
            avatarKey = try await ImageUploaderService.shared.uploadAvatar(imageData: data)
        }

        let payload = UserUpdatePayload(
            full_name: fullName?.nilIfBlank(),
            city: city?.nilIfBlank(),
            show_city: showCity,
            bio: bio?.nilIfBlank(),
            birth_date: birthDate,
            show_birth_date: showBirthDate,
            avatar_url: avatarKey,
            profession: profession?.nilIfBlank()
        )

        // Update users table
        try await supabase.from("users")
            .update(payload)
            .eq("id", value: userId)
            .execute()

        // Fetch and return the updated user
        let updated: User = try await supabase.from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        return updated
    }
}
private struct UserUpdatePayload: Encodable {
    let full_name: String?
    let city: String?
    let show_city: Bool?
    let bio: String?
    let birth_date: Date?
    let show_birth_date: Bool?
    let avatar_url: String?
    let profession: String?
}

extension String {
    func nilIfBlank() -> String? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

