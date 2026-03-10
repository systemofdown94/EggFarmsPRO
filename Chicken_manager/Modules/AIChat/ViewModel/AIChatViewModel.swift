import Foundation
import Combine

@available(iOS 26.0, *)
final class AIChatViewModel: ObservableObject {
    
    private var service: NativeLLMService?
    
    @Published var enteredText = ""
    @Published var isLoading = false 
    
    @Published private(set) var chat = AIChat(isMock: false)
    
    init() {
        do {
            service = try NativeLLMService()
        } catch let error as AIChatError {
            print(error.message)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Public API:
@available(iOS 26.0, *)
extension AIChatViewModel {
    func sendMessage(with text: String? = nil) {
        let newMessageText = text ?? enteredText
        
        chat.messages.append(Message(text: newMessageText, isUser: true))
    
        isLoading = true
        enteredText = ""
        
        Task { [weak self] in
            guard let self,
                  let service else { return }
            
            do {
                let response = try await service.sendMessage(with: text ?? enteredText)
                
                await MainActor.run {
                    self.isLoading = false
                    self.chat.messages.append(Message(text: response, isUser: false))
                }
            } catch let error as AIChatError {
                print(error.message)
                
                await MainActor.run {
                    self.isLoading = false 
                }
            }
        }
    }
    
    func removeChat() {
        chat = AIChat(isMock: false)
    }
}

