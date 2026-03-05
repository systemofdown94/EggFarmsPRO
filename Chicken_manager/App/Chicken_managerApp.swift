import SwiftUI

@main
struct Chicken_managerApp: App {
    
    @AppStorage("hasOnboardingCompleted") private var hasOnboardingCompleted = false
    
    var body: some Scene {
        WindowGroup {
            if hasOnboardingCompleted {
                AppTabView()
                    .transition(.opacity)
            } else {
                OnboardingView()
            }
        }
    }
}
