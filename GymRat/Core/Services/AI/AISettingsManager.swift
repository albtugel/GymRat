import Foundation
import Observation

@Observable
@MainActor
final class AISettingsManager {
    private enum Keys {
        static let chatModel = "ai.chatModel"
        static let voiceModel = "ai.voiceModel"
        static let apiKeyAccount = "mistral.apiKey"
    }

    static let defaultChatModel = "mistral-medium-3-5"
    static let defaultVoiceModel = "voxtral-mini-latest"

    private let defaults: UserDefaults
    private let keychain: KeychainStore
    private let apiKeyValidator: MistralAPIKeyValidating

    var chatModel: String {
        didSet { defaults.set(chatModel, forKey: Keys.chatModel) }
    }

    var voiceModel: String {
        didSet { defaults.set(voiceModel, forKey: Keys.voiceModel) }
    }

    private(set) var hasAPIKey: Bool = false
    private(set) var isSavingAPIKey = false
    private(set) var errorMessage: String?

    init(
        defaults: UserDefaults = .standard,
        keychain: KeychainStore = KeychainStore(),
        apiKeyValidator: MistralAPIKeyValidating = MistralAPIKeyValidator()
    ) {
        self.defaults = defaults
        self.keychain = keychain
        self.apiKeyValidator = apiKeyValidator
        chatModel = defaults.string(forKey: Keys.chatModel) ?? Self.defaultChatModel
        voiceModel = defaults.string(forKey: Keys.voiceModel) ?? Self.defaultVoiceModel
        refreshAPIKeyState()
    }

    func apiKey() throws -> String? {
        try keychain.string(for: Keys.apiKeyAccount)
    }

    func saveAPIKey(_ value: String) async {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        isSavingAPIKey = true
        defer { isSavingAPIKey = false }
        do {
            if trimmed.isEmpty {
                try keychain.deleteString(for: Keys.apiKeyAccount)
            } else {
                try await apiKeyValidator.validate(apiKey: trimmed)
                try keychain.setString(trimmed, for: Keys.apiKeyAccount)
            }
            errorMessage = nil
            refreshAPIKeyState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteAPIKey() {
        do {
            try keychain.deleteString(for: Keys.apiKeyAccount)
            errorMessage = nil
            refreshAPIKeyState()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    private func refreshAPIKeyState() {
        let value = try? keychain.string(for: Keys.apiKeyAccount)
        hasAPIKey = value?.isEmpty == false
    }
}
