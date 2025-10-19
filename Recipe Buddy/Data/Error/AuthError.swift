import Foundation
import Supabase

enum AuthError: LocalizedError, Identifiable {
    var id: String { self.localizedDescription }
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case networkError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol edip tekrar deneyin."
        case .emailAlreadyInUse:
            return "Bu e-posta adresi zaten kullanılıyor. Lütfen farklı bir e-posta adresi deneyin veya şifrenizi sıfırlayın."
        case .weakPassword:
            return "Şifreniz çok zayıf. Lütfen en az 6 karakterden oluşan daha güçlü bir şifre seçin."
        case .networkError:
            return "İnternet bağlantınızda bir sorun var gibi görünüyor. Lütfen bağlantınızı kontrol edip tekrar deneyin."
        case .unknown(let error):
            // For debug
            print("Bilinmeyen Hata: \(error.localizedDescription)")
            return "Beklenmedik bir hata oluştu. Lütfen daha sonra tekrar deneyin."
        }
    }
    
    // Supabase'den gelen genel hatayı kendi özel hata tipimize çeviriyoruz.
    static func from(supabaseError: Error) -> AuthError {
        let description = supabaseError.localizedDescription.lowercased()
        
        if description.contains("invalid login credentials") {
            return .invalidCredentials
        } else if description.contains("email address already in use") {
            return .emailAlreadyInUse
        } else if description.contains("password should be at least 6 characters") {
            return .weakPassword
        } else if let urlError = supabaseError as? URLError, urlError.code == .notConnectedToInternet {
            return .networkError(supabaseError)
        } else {
            return .unknown(supabaseError)
        }
    }
}
