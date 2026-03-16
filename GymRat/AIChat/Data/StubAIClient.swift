import Foundation

struct StubAIClient: AIClient {
    func send(request: AIChatRequest) async throws -> AIChatResponse {
        let prompts = [
            String(localized: "ai_prompt_sleep"),
            String(localized: "ai_prompt_food"),
            String(localized: "ai_prompt_calories"),
            String(localized: "ai_prompt_height_weight"),
            String(localized: "ai_prompt_feeling")
        ]

        let userCount = request.messages.filter { $0.role == .user }.count
        let index = min(userCount, prompts.count - 1)
        let reply = prompts[index]

        return AIChatResponse(text: reply, programChangeRequest: nil)
    }
}
