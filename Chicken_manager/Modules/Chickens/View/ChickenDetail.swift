import SwiftUI

struct ChickenDetail: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var viewModel: ChickensViewModel
    
    let chicken: Chicken
    
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 16) {
                navigationBar
                
                ScrollView(showsIndicators: false) {
                    image
                    info
                    buttons
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden()
    }
    
    private var background: some View {
        Image(.BG)
            .resizeCrop()
    }
    
    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.appOrange)
            }
            .frame(width: 40, height: 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
    }
    
    private var image: some View {
        Image(uiImage:  chicken.image ?? UIImage())
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width - 32, height: 350)
            .clipped()
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
            .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
            .padding(.horizontal, 16)
    }
    
    private var info: some View {
        VStack(spacing: 16) {
            Text(chicken.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.inter(.bold, size: 38))
                .foregroundStyle(.appBrown)
            
            VStack(spacing: 8) {
                Text(chicken.breed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(Date.ageString(from: chicken.birthDate))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.inter(.medium, size: 19))
            .foregroundStyle(.appLightBrown)
            
            VStack(spacing: 8) {
                Text("Productivity")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.inter(.semibold, size: 19))
                    .foregroundStyle(.appBrown)
                
                VStack(spacing: 4) {
                    HStack {
                        Text("Eggs per week:")
                            .foregroundStyle(.appLightBrown)
                        
                        Text(chicken.eggsPerWeek.formatted())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.appBrown)
                    }
                    
                    HStack {
                        Text("Total eggs:")
                            .foregroundStyle(.appLightBrown)
                        
                        Text(Date.multiplyByWeeksSince(chicken.eggsPerWeek, from: chicken.birthDate).formatted())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.appBrown)
                    }
                }
                .font(.inter(.semibold, size: 19))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(.appOrange)
            .cornerRadius(16)
        }
        .padding(.horizontal, 16)
    }
    
    private var buttons: some View {
        HStack(spacing: 30) {
            Button {
                viewModel.navigationPath.append(.new(chicken))
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.appOrange, lineWidth: 2)
                    .frame(height: 63)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        Text("Edit")
                            .font(.inter(.semibold, size: 19))
                            .foregroundStyle(.appOrange)
                    }
            }
            
            Button {
                viewModel.remove(chicken)
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.red, lineWidth: 2)
                    .frame(height: 63)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        Text("Delete")
                            .font(.inter(.semibold, size: 19))
                            .foregroundStyle(.red)
                    }
            }
        }
        .padding(.top)
        .padding(.horizontal, 1)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ChickenDetail(chicken: Chicken(isMock: true))
}

