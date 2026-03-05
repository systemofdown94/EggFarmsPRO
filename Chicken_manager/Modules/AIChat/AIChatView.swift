import SwiftUI

@available(iOS 26.0, *)
struct AIChatView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = AIChatViewModel()
    
    @State private var keyboardHeight: CGFloat = 0
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack {
            background
            
            GeometryReader { _ in
                VStack(spacing: 16) {
                    navigationBar
                    
                    if viewModel.chat.messages.isEmpty && !viewModel.isLoading {
                        stumb
                    } else {
                        chat
                    }
                    
                    input
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarBackButtonHidden()
        .animation(.default, value: isFocused)
        .animation(.default, value: viewModel.chat)
        .animation(.default, value: viewModel.isLoading)
        .onAppear {
            AppTabAppearanceManager.shared.hide()
        }
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
                
                Spacer()
                
                Button {
                    viewModel.removeChat()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.red)
                }
                .frame(width: 40, height: 40)
            }
            
            Text("AI Assistant")
                .font(.inter(.semibold, size: 28))
                .foregroundStyle(.appBrown)
        }
        .frame(height: 80)
        .background(.appOrange)
    }
    
    private var stumb: some View {
        VStack {
            VStack {
                Image(.Icons.aiChatStumb)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("Ask a question about your chickens and get recommendations.")
                    .font(.inter(.bold, size: 32))
                    .foregroundStyle(.appBrown)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            LazyVGrid(columns: [GridItem(spacing: 20), GridItem(spacing: 20)], spacing: 20) {
                ForEach(MessagesVariant.allCases) { variant in
                    Button {
                        viewModel.sendMessage(with: variant.message)
                    } label: {
                        Text(variant.message)
                            .frame(height: 70)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.inter(.medium, size: 16))
                            .foregroundStyle(.appBrown)
                            .background(Color(hex: "#FFE2CF"))
                            .multilineTextAlignment(.leading)
                            .cornerRadius(16)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.appBrown, lineWidth: 1)
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .opacity(isFocused ? 0 : 1)
    }
    
    private var chat: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(viewModel.chat.messages) { message in
                        HStack {
                            HStack {
                                HStack {
                                    if !message.isUser {
                                        VStack {
                                            Image(.Icons.Mock.mockChicken)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 70, height: 70)
                                        }
                                        .frame(maxHeight: .infinity, alignment: .top)
                                    }
                                    
                                    VStack {
                                        if !message.isUser {
                                            Text("Snowy")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.inter(.semibold, size: 19))
                                                .foregroundStyle(.red)
                                        }
                                        
                                        Text(LocalizedStringKey(message.text))
                                            .font(.inter(.medium, size: 15))
                                            .foregroundStyle(.appBrown)
                                    }
                                    .frame(maxHeight: .infinity, alignment: .top)
                                }
                                .padding(12)
                                .background(.appBeige)
                                .clipShape(
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: 16,
                                        bottomLeadingRadius: message.isUser ? 16 : 0,
                                        bottomTrailingRadius: message.isUser ? 0 : 16,
                                        topTrailingRadius: 16
                                    )
                                )
                                .overlay {
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: 16,
                                        bottomLeadingRadius: message.isUser ? 16 : 0,
                                        bottomTrailingRadius: message.isUser ? 0 : 16,
                                        topTrailingRadius: 16
                                    )
                                    .stroke(.appBrown, lineWidth: 1)
                                }
                            }
                            .id(message.id)
                            .frame(maxWidth: UIScreen.main.bounds.width * 2/3, alignment: message.isUser ? .trailing : .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                    }
                    
                    if viewModel.isLoading {
                        HStack {
                            ActivityDotsView()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Color.clear
                        .frame(height: 20)
                }
                .padding(.top, 5)
                .padding(.horizontal, 16)
            }
            .onChange(of: viewModel.chat) { count in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        guard let last = viewModel.chat.messages.last else { return }
                        proxy.scrollTo(last.id, anchor: .top)
                    }
                }
            }
        }
    }
    
    private var input: some View {
        HStack {
            TextField("", text: $viewModel.enteredText, prompt: Text("Type your question...")
                .foregroundColor(.appBrown.opacity(0.5))
            )
            .foregroundColor(.appBrown)
            .font(.inter(.medium, size: 20))
            .focused($isFocused)
            
            Button {
                viewModel.sendMessage()
                isFocused = false
            } label: {
                Image(systemName: "arrowtriangle.forward.fill")
                    .font(.system(size: 20, weight: .medium))
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .background(.appOrange)
                    .foregroundStyle(.white)
            }
        }
        .frame(height: 52)
        .padding(.leading, 12)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, y: 4)
        .padding(.horizontal, 16)
        .keyboardHeight($keyboardHeight)
        .offset(y: keyboardHeight == 0 ? 0 : -keyboardHeight)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        AIChatView()
    }
}
