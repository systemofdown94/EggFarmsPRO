import SwiftUI
import SwipeActions

struct EggLogView: View {
    
    @StateObject private var viewModel = EggLogViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                background
                
                VStack(spacing: 16) {
                    navigationBar
                    
                    if viewModel.chickens.isEmpty {
                        stumb
                    } else {
                        chickensList
                        totalEggs
                        history
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .animation(.default, value: viewModel.chickens)
            .animation(.default, value: viewModel.currentChicken)
            .navigationDestination(for: EgglogScreens.self) { screen in
                switch screen {
                    case .add(let note):
                        AddEggNoteView(note: note)
                }
            }
            .onAppear {
                AppTabAppearanceManager.shared.show()
                viewModel.loadChickens()
            }
            .onChange(of: viewModel.chickens) { chickens in
                viewModel.currentChicken = chickens.first ?? Chicken(isMock: true)
            }
        }
        .environmentObject(viewModel)
    }
    
    private var background: some View {
        Image(.Images.mainBG)
            .resizeCrop()
    }
    
    private var navigationBar: some View {
        HStack {
            Text("Egg Log")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.bold, size: 38))
                .foregroundStyle(.appBrown)
            
            Button {
                AppTabAppearanceManager.shared.hide()
                viewModel.navigationPath.append(.add(EggNote()))
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
        }
        .frame(height: 80)
        .padding(.horizontal, 16)
    }
    
    private var stumb: some View {
        VStack {
            Text("There are no eggs log yet")
                .font(.inter(.bold, size: 24))
                .foregroundStyle(.appBrown)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var chickensList: some View {
        TabView(selection: $viewModel.currentChicken) {
            ForEach(viewModel.chickens) { chicken in
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
                }
                .tag(chicken)
                .padding(.horizontal, 12)
                .frame(width: UIScreen.main.bounds.width - 32, height: 100)
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 120)
    }
    
    private var totalEggs: some View {
        HStack {
            VStack(spacing: 0) {
                Text("Total Eggs")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.medium, size: 19))
                    .foregroundStyle(.appLightBrown)
                
                HStack {
                    Image(.Icons.AppTab.eggLog)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 20)
                        .foregroundStyle(.appBrown)
                    
                    let allEggs = Date.multiplyByWeeksSince(viewModel.currentChicken.eggsPerWeek, from: viewModel.currentChicken.birthDate)
                    let eggCount = viewModel.currentChicken.eggNotes.reduce(0) { $0 + $1.count }
                    let sum = allEggs + eggCount
                    
                    Text(sum.formatted())
                        .font(.inter(.semibold, size: 28))
                        .foregroundStyle(.appLightBrown)
                    
                    Text("Eggs")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.inter(.medium, size: 19))
                        .foregroundStyle(.appBrown)
                }
            }
            
            VStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                    
                    Text("This week:")
                        .font(.inter(.medium, size: 14))
                        .foregroundStyle(Color(hex: "#8B5F4C"))
                    
                    Text((viewModel.currentChicken.eggsThisWeek + viewModel.currentChicken.eggsPerWeek).formatted())
                        .font(.inter(.semibold, size: 19))
                }
                .frame(height: 36)
                .padding(.horizontal, 8)
                .background(.appOrange)
                .cornerRadius(16)
                
                HStack(spacing: 4) {
                    Image(.Icons.EggLog.graph)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.white)
                    
                    Text("Avg/Week:")
                        .font(.inter(.medium, size: 14))
                        .foregroundStyle(Color(hex: "#8B5F4C"))
                    
                    Text(Int(viewModel.currentChicken.averageEggsPerWeek).formatted())
                        .font(.inter(.semibold, size: 19))
                }
                .frame(height: 36)
                .padding(.horizontal, 8)
                .background(.appOrange)
                .cornerRadius(16)
            }
        }
        .padding(16)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
    
    private var history: some View {
        VStack(spacing: 16) {
            HStack {
                Text("History")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.bold, size: 28))
                    .foregroundStyle(.appBrown)
                
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.appOrange)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            
            if viewModel.currentChicken.eggNotes.isEmpty {
                Text("There is no history yet")
                    .font(.inter(.bold, size: 24))
                    .foregroundStyle(.appBrown)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.currentChicken.eggNotes) { note in
                            SwipeView {
                                HStack {
                                    Text(note.date.formatted(.dateTime.year().month(.abbreviated).day(.twoDigits)))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.inter(.medium, size: 19))
                                        .foregroundStyle(.appLightBrown)
                                    
                                    HStack {
                                        Image(.Icons.AppTab.eggLog)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                            .foregroundStyle(.white)
                                        
                                        Text(note.count.formatted())
                                            .font(.inter(.semibold, size: 28))
                                            .foregroundStyle(.appBrown)
                                    }
                                    .frame(maxHeight: .infinity)
                                    .padding(.horizontal, 8)
                                    .background(.appOrange)
                                }
                                .frame(height: 52)
                                .padding(.leading, 12)
                                .background(.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
                            } trailingActions: { context in
                                Button {
                                    context.state.wrappedValue = .closed
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        AppTabAppearanceManager.shared.hide()
                                        viewModel.navigationPath.append(.add(note))
                                    }
                                } label: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .frame(width: 48, height: 48)
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
                                    viewModel.removeEgg(note)
                                } label: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .frame(width: 48, height: 48)
                                        .foregroundStyle(.red)
                                        .overlay {
                                            Image(systemName: "trash")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundStyle(.appLightBeige)
                                        }
                                }
                            }
                            .swipeMinimumDistance(30)
                            .swipeActionWidth(50)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

#Preview {
    EggLogView()
}
