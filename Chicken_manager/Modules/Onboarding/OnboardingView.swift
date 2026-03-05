import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("hasOnboardingCompleted") private var hasOnboardingCompleted = false
    
    @State private var currentIndex = 0
    
    var page: OnboardingPage {
        OnboardingPage(rawValue: currentIndex) ?? .page1
    }
    
    var body: some View {
        ZStack {
            background
            pageData
        }
    }
    
    private var background: some View {
        Image(.Images.mainBG)
            .resizeCrop()
    }
    
    private var pageData: some View {
        VStack {
            switch page {
                case .page1:
                    page1Data
                case .page2:
                    page2Data
                case .page3:
                    page3Data
            }
            
            continueButton
            pageController
        }
        .padding(.horizontal, 24)
    }
    
    private var page1Data: some View {
        VStack(spacing: 0) {
            Image(.Images.Onboarding.chicken)
                .resizable()
                .scaledToFit()
                .clipped()
            
            VStack(spacing: 16) {
                VStack(spacing: 0) {
                    Text("Welcome to")
                        .font(.inter(.bold, size: 18))
                    
                    Text("Chicken Manager")
                        .font(.inter(.bold, size: 24))
                }
                
                Text("Manage your hens, track egg\nproduction, and optimize\nproductivity.")
                    .font(.inter(.semibold, size: 18))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.appBrown)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var page2Data: some View {
        VStack(spacing: 30) {
            ForEach(Page2Data.allCases) { data in
                VStack {
                    Circle()
                        .frame(width: 90, height: 90)
                        .foregroundStyle(.appBeige)
                        .overlay {
                            Image(data.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                    
                    Text(data.title)
                        .font(.inter(.semibold, size: 24))
                        .foregroundStyle(.appBrown)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var page3Data: some View {
        VStack {
            Text("Start right\nnow!")
                .font(.inter(.bold, size: 54))
                .multilineTextAlignment(.center)
                .foregroundStyle(.appBrown)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var continueButton: some View {
        Button {
            nextPage()
        } label: {
            Text("Next")
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .font(.inter(.semibold, size: 19))
                .foregroundStyle(.appLightBeige)
                .background(.appOrange)
                .cornerRadius(20)
        }
    }
    
    private var pageController: some View {
        HStack(spacing: 8) {
            ForEach(0..<OnboardingPage.allCases.count, id: \.self) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundStyle(.appOrange.opacity(index == currentIndex ? 1 : 0.3))
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 24)
    }
    
    private func nextPage() {
        let isLastPage = page == .page3
        
        HapticService.shared.impact()
        
        if isLastPage {
            withAnimation {
                hasOnboardingCompleted = true
            }
        } else {
            currentIndex += 1
        }
    }
}

#Preview {
    OnboardingView()
}

