import SwiftUI

struct AppTabView: View {
    
    @ObservedObject private var tabBarManager = AppTabAppearanceManager.shared
    
    @State private var currentTab: AppTab = .chickens
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            tabView
            tabBar
        }
    }
    
    private var background: some View {
        Image(.BG)
            .resizeCrop()
    }
    
    private var tabView: some View {
        TabView(selection: $currentTab) {
            ChickensView()
                .tag(AppTab.chickens)
                .toolbar(.hidden, for: .tabBar)
            
            EggLogView()
                .tag(AppTab.eggLog)
                .toolbar(.hidden, for: .tabBar)
            
            StatisticsView()
                .tag(AppTab.statistics)
                .toolbar(.hidden, for: .tabBar)
            
            SettingsView()
                .tag(AppTab.settings)
                .toolbar(.hidden, for: .tabBar)
        }
    }
    
    private var tabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray.opacity(0.5))
            
            HStack {
                ForEach(AppTab.allCases) { tab in
                    Button {
                        HapticService.shared.impact()
                        currentTab = tab
                    } label: {
                        VStack {
                            if tab == currentTab {
                                RoundedRectangle(cornerRadius: 10, )
                                    .frame(width: 40, height: 3)
                                    .foregroundStyle(.appOrange)
                            }
                            
                            Spacer()
                                .frame(height: 16)
                            
                            VStack(spacing: 12) {
                                Image(tab.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                
                                Text(tab.title)
                                    .font(.inter(.semibold, size: 12))
                            }
                            .foregroundStyle(tab == currentTab ? .appOrange : .appBrown)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(.appLightBeige)
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .opacity(tabBarManager.shouldShowTabBar ? 1 : 0)
        .animation(.default, value: tabBarManager.shouldShowTabBar)
    }
}

#Preview {
    AppTabView()
}
