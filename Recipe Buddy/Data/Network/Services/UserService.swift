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
}
