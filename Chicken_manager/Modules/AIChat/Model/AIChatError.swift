import UIKit

enum AIChatError: Error {
    case initError
    case emptyResponse
    
    var message: String {
        switch self {
            case .initError:
                "The service is not available. Please try again later."
            case .emptyResponse:
                "The service did not return a response. Please try again later."
        }
    }
}
