import Foundation

struct GenerateAIReplyUseCase {
    let client: AIClient
    let summaryUseCase: BuildWorkoutSummaryUseCase

    func execute(messages: [ChatMessage]) async throws -> AIChatResponse {
        let summary = summaryUseCase.execute()
        let context = AIChatContext(workoutSummary: summary)
        let mapped = messages.map {
            AIChatMessage(
                role: $0.isUser ? .user : .assistant,
                text: $0.text
            )
        }
        let request = AIChatRequest(messages: mapped, context: context)
        return try await client.send(request: request)
    }
}
