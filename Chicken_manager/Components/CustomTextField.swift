import SwiftUI

struct CustomTextField: View {
    
    @Binding var text: String
    
    let placeholder: String
    
    @FocusState.Binding var isFocused: Bool
    
    var body: some View {
        HStack {
            TextField("", text: $text, prompt: Text(placeholder)
                .foregroundColor(.appBrown.opacity(0.5))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.inter(.medium, size: 19))
            .foregroundStyle(.appBrown)
            .focused($isFocused)
            
            if text != "" {
                Button {
                    text = ""
                    isFocused = false
                } label: {
                    Image(systemName: "multiply.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.appBrown.opacity(0.5))
                }
            }
        }
        .frame(height: 42)
        .padding(.horizontal, 12)
        .background(.white)
        .cornerRadius(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.appBrown, lineWidth: 1)
        }
    }
}
