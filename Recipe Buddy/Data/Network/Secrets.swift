import Foundation

enum Secrets {
    private static var keys: [String: Any]? {
        guard let path = Bundle.main.path(forResource: "SupabaseKeys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("❌ SupabaseKeys.plist dosyası bulunamadı veya okunamadı.")
        }
        return dict
    }

    static var supabaseURL: URL {
        guard let urlString = keys?["SUPABASE_URL"] as? String,
              let url = URL(string:urlString) else {
            fatalError("❌ SupabaseKeys.plist içinde SUPABASE_URL anahtarı bulunamadı veya geçerli bir URL değil.")
        }
        return url
    }

    static var supabaseKey: String {
        guard let key = keys?["SUPABASE_KEY"] as? String else {
            fatalError("❌ SupabaseKeys.plist içinde SUPABASE_KEY anahtarı bulunamadı.")
        }
        return key
    }
}
