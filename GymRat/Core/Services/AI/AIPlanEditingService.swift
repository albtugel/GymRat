import Foundation

final class AIPlanEditingService {
    private let chatClient: MistralChatCompleting
    private let transcriptionClient: MistralTranscribing

    init(
        chatClient: MistralChatCompleting = MistralChatClient(),
        transcriptionClient: MistralTranscribing = MistralTranscriptionClient()
    ) {
        self.chatClient = chatClient
        self.transcriptionClient = transcriptionClient
    }

    func generatePlanEdit(
        apiKey: String,
        model: String,
        prompt: String,
        programName: String,
        programType: ProgramType,
        selectedExercises: [WorkoutExercise],
        availableExerciseNames: [String]
    ) async throws -> AIPlanEditResponse {
        let trimmed = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AIPlanEditError.emptyPrompt
        }
        let messages = AIPlanEditPromptBuilder.messages(
            prompt: trimmed,
            programName: programName,
            programType: programType,
            selectedExercises: selectedExercises,
            availableExerciseNames: availableExerciseNames
        )
        let content = try await chatClient.completeJSON(apiKey: apiKey, model: model, messages: messages)
        return try AIPlanEditParser.decode(content)
    }

    func transcribe(apiKey: String, model: String, audioFileURL: URL) async throws -> String {
        try await transcriptionClient.transcribe(apiKey: apiKey, model: model, audioFileURL: audioFileURL)
    }
}
