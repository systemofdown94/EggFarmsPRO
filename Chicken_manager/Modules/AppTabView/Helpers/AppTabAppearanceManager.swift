import Foundation
import Combine

final class AppTabAppearanceManager: ObservableObject {
    
    static let shared = AppTabAppearanceManager()
    
    @Published private(set) var shouldShowTabBar = true
    
    private init() {}
    
    func show() {
        shouldShowTabBar = true
    }
    
    func hide() {
        shouldShowTabBar = false
    }
}
