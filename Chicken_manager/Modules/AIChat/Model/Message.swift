import Foundation

struct Message: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isUser: Bool
    
    init(isMock: Bool) {
        self.id = UUID()
        self.text = isMock ? "Hello, world!" : ""
        self.isUser = false
    }
    
    init(text: String, isUser: Bool) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
    }
}
