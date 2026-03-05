import SwiftUI

struct UserView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var userModel: UserModel
    
    @State private var newName = ""
    @State private var selectedType: UserType
    
    init(userModel: UserModel) {
        self.userModel = userModel
        self.selectedType = userModel.type
    }
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 16) {
                navigationBar
                user
                types
                
                Spacer()
                
                saveButton
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .navigationBarBackButtonHidden()
    }
    
    private var background: some View {
        Image(.BG)
            .resizeCrop()
    }
    
    private var navigationBar: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.appBeige)
                }
                .frame(width: 40, height: 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Profile")
                .font(.inter(.semibold, size: 28))
                .foregroundStyle(.appBrown)
        }
        .frame(height: 80)
        .background(.appOrange)
    }
    
    private var user: some View {
        VStack {
            HStack {
                Image(userModel.type.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                
                VStack {
                    Text(userModel.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.inter(.semibold, size: 19))
                        .foregroundStyle(.appBrown)
                    
                    VStack(spacing: 4) {
                        Text(userModel.type.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(userModel.type.subtitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundStyle(.appLightBrown)
                }
            }
            
            HStack {
                TextField("", text: $newName, prompt: Text("Enter new name")
                    .foregroundColor(.black.opacity(0.3))
                )
                .font(.inter(.medium, size: 20))
                .focused($isFocused)
                
                if newName != "" {
                    Button {
                        newName = ""
                        isFocused = false
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.black.opacity(0.3))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 35)
            .padding(.horizontal, 12)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.appOrange, lineWidth: 1)
            }
        }
        .frame(height: 190)
        .padding(16)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        .padding(.horizontal, 16)
    }
    
    private var types: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(spacing: 30), count: 3),
            spacing: 20
        ) {
            ForEach(UserType.allCases) { type in
                Button {
                    selectedType = type
                } label: {
                    Image(type.icon)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .overlay {
                            if type == selectedType {
                                Circle()
                                    .stroke(.appOrange, lineWidth: 5)
                                    .frame(width: 80, height: 80)
                            }
                        }
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        .padding(.horizontal, 16)
    }
    
    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text("Save")
                .frame(width: 270, height: 52)
                .font(.inter(.semibold, size: 19))
                .foregroundStyle(.appLightBeige)
                .background(.orange)
                .cornerRadius(16)
        }
    }
    
    private func save() {
        userModel.name = newName == "" ? userModel.name : newName
        userModel.type = selectedType
        
        Task {
            await UserDefaultsService.shared.save(userModel, forKey: .user)
            
            await MainActor.run {
                dismiss()
            }
        }
    }
}

#Preview {
    UserView(userModel: UserModel())
}
