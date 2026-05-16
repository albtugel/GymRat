import SwiftUI

struct AISection: View {
    private let aiSettingsManager: AISettingsManager
    @State private var apiKeyText = ""
    @State private var isEditingSavedKey = false

    init(aiSettingsManager: AISettingsManager) {
        self.aiSettingsManager = aiSettingsManager
    }

    var body: some View {
        Section {
            if aiSettingsManager.hasAPIKey && !isEditingSavedKey {
                savedKeyContent
            } else {
                keyEntryContent
            }

            if let errorMessage = aiSettingsManager.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("aiSettingsAPIKeyErrorLabel")
            }
        } header: {
            Text("ai_api_setup_section")
        } footer: {
            Text("ai_privacy_note")
        }
    }

    private var savedKeyContent: some View {
        Group {
            AIAPIKeyStatusRow()
                .accessibilityIdentifier("aiSettingsAPIKeySavedLabel")

            Button("ai_replace_key_button") {
                isEditingSavedKey = true
                apiKeyText = ""
            }
            .accessibilityIdentifier("aiSettingsReplaceKeyButton")

            Button("ai_delete_key_button", role: .destructive) {
                aiSettingsManager.deleteAPIKey()
                isEditingSavedKey = false
                apiKeyText = ""
            }
            .accessibilityIdentifier("aiSettingsDeleteKeyButton")
        }
    }

    private var keyEntryContent: some View {
        Group {
            SecureField("ai_api_key_placeholder", text: $apiKeyText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier("aiSettingsAPIKeyField")

            Button {
                Task {
                    await aiSettingsManager.saveAPIKey(apiKeyText)
                    if aiSettingsManager.hasAPIKey {
                        apiKeyText = ""
                        isEditingSavedKey = false
                    }
                }
            } label: {
                if aiSettingsManager.isSavingAPIKey {
                    HStack {
                        ProgressView()
                        Text("ai_verifying_key_button")
                    }
                } else {
                    Text("ai_save_key_button")
                }
            }
            .disabled(isSaveDisabled)
            .accessibilityIdentifier("aiSettingsSaveKeyButton")

            if aiSettingsManager.hasAPIKey {
                Button("cancel_button", role: .cancel) {
                    apiKeyText = ""
                    isEditingSavedKey = false
                    aiSettingsManager.dismissError()
                }
                .accessibilityIdentifier("aiSettingsCancelKeyEditButton")
            }
        }
    }

    private var isSaveDisabled: Bool {
        apiKeyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiSettingsManager.isSavingAPIKey
    }
}
