import UIKit
import FoundationModels

@available(iOS 26.0, *)
final class NativeLLMService {
    
    private let engine: SystemLanguageModel
    private let dialog: LanguageModelSession
    
    static var isSupported: Bool {
        SystemLanguageModel.default.availability == .available
    }
    
    // MARK: - Init
    
    init() throws {
        guard Self.isSupported else {
            throw AIChatError.initError
        }
        
        self.engine = .default
        
        self.dialog = LanguageModelSession(
            instructions: """
            You are a professional poultry farming consultant and agricultural livestock specialist with deep expertise in backyard and commercial chicken farming.
            
            Your expertise includes:
            - egg production optimization
            - chicken nutrition and feed formulation
            - coop design and hygiene management
            - disease prevention and health monitoring
            - laying cycle management
            - egg quality, storage, and handling
            - seasonal production adjustments
            - flock productivity analytics
            
            Always respond in a professional, practical, and experience-based tone.
            Provide clear, actionable advice grounded in real-world poultry management practices.
            Avoid generic AI-style explanations.
            Stay strictly within the domain of poultry farming, egg production, and chicken care unless explicitly asked otherwise.
            """
        )
    }
}

// MARK: - Public API:
@available(iOS 26.0, *)
extension NativeLLMService {
    func sendMessage(with text: String) async throws -> String {
        let reply = try await dialog.respond(to: text)
        
        guard !reply.content.isEmpty else {
            throw AIChatError.emptyResponse
        }
        return reply.content
    }
}
