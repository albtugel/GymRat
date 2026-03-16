import Foundation
import SwiftData

@MainActor
final class AIChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var pendingChanges: ProgramChangeRequest?

    private var chatRepository: ChatMessageRepository?
    private var replyUseCase: GenerateAIReplyUseCase?
    private var didConfigure = false
    private var didSeedInitial = false

    func configureIfNeeded(context: ModelContext) {
        guard !didConfigure else { return }
        didConfigure = true

        let chatRepo = SwiftDataChatMessageRepository(context: context)
        let logRepo = SwiftDataWorkoutLogRepository(context: context)
        let summaryUseCase = BuildWorkoutSummaryUseCase(repository: logRepo)
        let aiClient = StubAIClient()
        let replyUseCase = GenerateAIReplyUseCase(client: aiClient, summaryUseCase: summaryUseCase)

        self.chatRepository = chatRepo
        self.replyUseCase = replyUseCase

        loadMessages()
        seedIfNeeded()
    }

    func loadMessages() {
        guard let chatRepository else { return }
        messages = (try? chatRepository.fetchAll()) ?? []
    }

    func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let chatRepository else { return }

        do {
            let message = try chatRepository.insert(role: .user, text: trimmed)
            messages.append(message)
        } catch {
            return
        }

        Task {
            await respondAsAssistant()
        }
    }

    func clearHistory() {
        guard let chatRepository else { return }
        do {
            try chatRepository.deleteAll()
            messages = []
            didSeedInitial = false
            seedIfNeeded()
        } catch {
            return
        }
    }

    private func seedIfNeeded() {
        guard !didSeedInitial, messages.isEmpty, let chatRepository else { return }
        didSeedInitial = true
        let greeting = String(localized: "ai_greeting")
        if let message = try? chatRepository.insert(role: .assistant, text: greeting) {
            messages.append(message)
        }
    }

    private func respondAsAssistant() async {
        guard let replyUseCase, let chatRepository else { return }
        do {
            let response = try await replyUseCase.execute(messages: messages)
            let message = try chatRepository.insert(role: .assistant, text: response.text)
            messages.append(message)
            pendingChanges = response.programChangeRequest
        } catch {
            let fallback = String(localized: "ai_fallback")
            if let message = try? chatRepository.insert(role: .assistant, text: fallback) {
                messages.append(message)
            }
        }
    }
}
