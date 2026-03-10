import SwiftUI

struct SplashScreen: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    @Binding var launchApp: Bool
    
    var body: some View {
        ZStack {
            Color.appLightBeige
                .ignoresSafeArea()
            
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
        }
        .ignoresSafeArea()
        .onAppear {
            appViewModel.loadLink()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                guard !launchApp else { return }
                launchApp = true
            }
        }
    }
}

#Preview {
    SplashScreen(launchApp: .constant(false))
}
