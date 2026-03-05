import SwiftUI
import SwipeActions

struct ChickensView: View {
    
    @StateObject private var viewModel = ChickensViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                background
                
                VStack(spacing: 16) {
                    navigationBar
                    chickens
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .animation(.default, value: viewModel.chickens)
            .navigationDestination(for: ChickensScreen.self) { screen in
                switch screen {
                    case .detail(let chicken):
                        ChickenDetail(chicken: chicken)
                    case .new(let chicken):
                        AddChickenView(chicken: chicken)
                    case .aiChat:
                        if #available(iOS 26.0, *) {
                            AIChatView()
                        }
                }
            }
            .onAppear {
                AppTabAppearanceManager.shared.show()
                viewModel.loadChickens()
            }
        }
        .environmentObject(viewModel)
    }
    
    private var background: some View {
        Image(.Images.BG)
            .resizeCrop()
    }
    
    private var navigationBar: some View {
        HStack {
            Text("Chickens")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.bold, size: 38))
                .foregroundStyle(.appBrown)
            
            HStack {
                Button {
                    AppTabAppearanceManager.shared.hide()
                    viewModel.navigationPath.append(.new(Chicken(isMock: false)))
                } label: {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 48, height: 48)
                        .foregroundStyle(.appOrange)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.appLightBeige)
                        }
                }
                
                if #available(iOS 26.0, *) {
                    Button {
                        viewModel.navigationPath.append(.aiChat)
                    } label: {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 48, height: 48)
                            .foregroundStyle(.appOrange)
                            .overlay {
                                Image(.Icons.aiChat)
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.appLightBeige)
                            }
                    }
                }
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var chickens: some View {
        if viewModel.chickens.isEmpty {
            stumb
        } else {
            chickensList
        }
    }
    
    private var chickensList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.chickens) { chicken in
                    SwipeView {
                        Button {
                            AppTabAppearanceManager.shared.hide()
                            viewModel.navigationPath.append(.detail(chicken))
                        } label: {
                            HStack(spacing: 10) {
                                if let image = chicken.image {
                                    Image(uiImage: image)
                                        .resizeCrop()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .cornerRadius(16)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(chicken.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.inter(.semibold, size: 19))
                                        .foregroundStyle(.appBrown)
                                    
                                    Text(chicken.breed)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.inter(.medium, size: 19))
                                        .foregroundStyle(.appLightBrown)
                                }
                                
                                Image(.Icons.forward)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 17)
                                    .foregroundStyle(.appOrange)
                            }
                            .frame(height: 100)
                            .padding(.horizontal, 12)
                            .background(.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
                        }
                    } trailingActions: { context in
                        Button {
                            context.state.wrappedValue = .closed
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                viewModel.navigationPath.append(.new(chicken))
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 64, height: 64)
                                .foregroundStyle(.appOrange)
                                .overlay {
                                    Image(.Icons.pen)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(.appLightBeige)
                                }
                        }
                        
                        Button {
                            viewModel.remove(chicken)
                        } label: {
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 64, height: 64)
                                .foregroundStyle(.red)
                                .overlay {
                                    Image(systemName: "trash")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundStyle(.appLightBeige)
                                }
                        }
                    }
                    .swipeMinimumDistance(30)
                    .swipeActionWidth(80)
                }
            }
            .padding(.top, 1)
            .padding(.horizontal, 16)
        }
    }
    
    private var stumb: some View {
        VStack {
            Text("There are no chickens yet")
                .font(.inter(.bold, size: 24))
                .foregroundStyle(.appBrown)
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    ChickensView()
}

