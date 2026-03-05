import UIKit

final class HapticService {
    
    static let shared = HapticService()
    
    private let generator = UIImpactFeedbackGenerator(style: .light)
    
    private init() {}
    
    func impact() {
        generator.prepare()
        generator.impactOccurred()
    }
}
