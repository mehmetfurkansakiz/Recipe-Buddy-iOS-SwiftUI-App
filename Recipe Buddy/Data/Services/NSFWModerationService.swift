import Foundation
import UIKit
import SensitiveContentAnalysis // iOS 17+

@MainActor
final class NSFWModerationService {
    static let shared = NSFWModerationService()
    
    private let analyzer = SCSensitivityAnalyzer()
    
    private init() {}

    enum Decision {
        case allowed
        case rejected
    }

    func check(image: UIImage) async -> Decision {
        guard let cgImage = image.cgImage else {
            print("⚠️ Görsel işlenemedi.")
            return .allowed
        }
        
        do {
            _ = analyzer.analysisPolicy
            
            let analysis = try await analyzer.analyzeImage(cgImage)
            
            if analysis.isSensitive {
                print("⛔️ Apple Sensitive Content: Uygunsuz içerik tespit edildi.")
                return .rejected
            } else {
                print("✅ Apple Sensitive Content: Görsel temiz.")
                return .allowed
            }
        } catch {
            print("❌ Analiz hatası: \(error)")
            return .allowed
        }
    }
}
