import Foundation
import Supabase

@MainActor
class UserService {
    static let shared = UserService()
    
    /// Fetches the complete profile for the currently logged-in user.
    func fetchCurrentUser() async throws -> User? {
        guard let userId = try? await supabase.auth.session.user.id else {
            return nil
        }
        
        do {
            let user: User = try await supabase
                .rpc("get_my_profile")
                .execute()
                .value
            
            return user
        } catch {
            print("❌ [UserService] fetchCurrentUser Hatası: \(error)")
            throw error
        }
    }
    
    /// Backward-compatible update without explicit remove flag
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
        return try await updateUserProfileWithAvatarControl(
            fullName: fullName,
            city: city,
            showCity: showCity,
            bio: bio,
            birthDate: birthDate,
            showBirthDate: showBirthDate,
            profession: profession,
            avatarImageData: avatarImageData,
            removeAvatar: false
        )
    }
    
    func updateEmailPreferences(newsletter: Bool, productUpdates: Bool, recipeTips: Bool) async throws -> User {
            guard let _ = try? await supabase.auth.session.user.id else {
                throw URLError(.userAuthenticationRequired)
            }

            struct UpdateEmailPreferencesParams: Encodable {
                let new_newsletter: Bool
                let new_product_updates: Bool
                let new_recipe_tips: Bool
            }

            let params = UpdateEmailPreferencesParams(
                new_newsletter: newsletter,
                new_product_updates: productUpdates,
                new_recipe_tips: recipeTips
            )

            do {
                let updatedUser: User = try await supabase
                    .rpc("update_email_preferences", params: params)
                    .execute()
                    .value
                
                print("✅ [UserService] Tercihler güncellendi.")
                return updatedUser
            } catch {
                print("❌ [UserService] updateEmailPreferences Hatası: \(error)")
                throw error
            }
        }

    /// Updates the current user's profile with explicit control over avatar removal
    func updateUserProfileWithAvatarControl(
        fullName: String?,
        city: String?,
        showCity: Bool,
        bio: String?,
        birthDate: Date?,
        showBirthDate: Bool,
        profession: String?,
        avatarImageData: Data?,
        removeAvatar: Bool
    ) async throws -> User {
        guard let userId = try? await supabase.auth.session.user.id else {
            throw URLError(.userAuthenticationRequired)
        }

        var avatarKey: String?? = nil
        if removeAvatar {
            avatarKey = .some(nil) // Explicitly set to NULL in DB
        } else if let data = avatarImageData {
            let uploadedKey = try await ImageUploaderService.shared.uploadAvatar(imageData: data)
            avatarKey = .some(uploadedKey)
        }

        let payload = UserUpdatePayloadWithNull(
            full_name: fullName?.nilIfBlank(),
            city: city?.nilIfBlank(),
            show_city: showCity,
            bio: bio?.nilIfBlank(),
            birth_date: birthDate,
            show_birth_date: showBirthDate,
            avatar_url: avatarKey,
            profession: profession?.nilIfBlank()
        )

        try await supabase.from("users")
            .update(payload)
            .eq("id", value: userId)
            .execute()

        let updated: User = try await supabase.from("users")
            .select("id, email, full_name, username")
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        return updated
    }
}

extension String {
    func nilIfBlank() -> String? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

