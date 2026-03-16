import Foundation

protocol AIClient {
    func send(request: AIChatRequest) async throws -> AIChatResponse
}
