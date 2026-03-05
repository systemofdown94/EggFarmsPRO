import Foundation

enum MessagesVariant: Identifiable, CaseIterable {
    case case1
    case case2
    case case3
    case case4
    
    var id: Self {
        self
    }
    
    var message: String {
        switch self {
            case .case1:
                "How to increase\negg production?"
            case .case2:
                "What is the best diet for laying hens?"
            case .case3:
                "How to keep chickens healthy?"
            case .case4:
                "How to improve eggshell quality?"
        }
    }
}
