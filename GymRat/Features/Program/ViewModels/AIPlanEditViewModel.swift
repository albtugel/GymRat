import Foundation
import Observation

@Observable
@MainActor
final class AIPlanEditViewModel {
    private let programEditorViewModel: ProgramEditorViewModel
    private let settingsManager: AISettingsManager
    private let editingService: AIPlanEditingService
    private let audioRecorder: AudioRecorder

    var prompt: String = ""
    var apiKeyInput: String = ""
    private(set) var transcript: String = ""
    private(set) var preview: AIPlanEditPreview?
    private(set) var isGenerating: Bool = false
    private(set) var isRecording: Bool = false
    private(set) var isTranscribing: Bool = false
    private(set) var errorMessage: String?
    private(set) var didApply: Bool = false
    private(set) var recordingStartedAt: Date?

    init(
        programEditorViewModel: ProgramEditorViewModel,
        settingsManager: AISettingsManager,
        editingService: AIPlanEditingService,
        audioRecorder: AudioRecorder
    ) {
        self.programEditorViewModel = programEditorViewModel
        self.settingsManager = settingsManager
        self.editingService = editingService
        self.audioRecorder = audioRecorder
    }

    var hasStoredAPIKey: Bool {
        settingsManager.hasAPIKey
    }

    var chatModel: String {
        settingsManager.chatModel
    }

    var voiceModel: String {
        settingsManager.voiceModel
    }

    var canGenerate: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && hasStoredAPIKey
            && !isGenerating
            && !isTranscribing
            && !settingsManager.isSavingAPIKey
    }

    var canRecord: Bool {
        hasStoredAPIKey && !isGenerating && !isTranscribing && !settingsManager.isSavingAPIKey
    }

    var isVerifyingAPIKey: Bool {
        settingsManager.isSavingAPIKey
    }

    var canVerifyAPIKey: Bool {
        !apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !settingsManager.isSavingAPIKey
    }

    var apiKeyErrorMessage: String? {
        settingsManager.errorMessage
    }

    func updatePrompt(_ value: String) {
        prompt = value
    }

    func updateAPIKeyInput(_ value: String) {
        apiKeyInput = value
    }

    func dismissError() {
        errorMessage = nil
    }

    func verifyAPIKey() async {
        guard canVerifyAPIKey else { return }
        await settingsManager.saveAPIKey(apiKeyInput)
        if settingsManager.hasAPIKey {
            apiKeyInput = ""
            errorMessage = nil
        }
    }

    func generatePreview() async {
        guard canGenerate else {
            errorMessage = hasStoredAPIKey
                ? AIPlanEditError.emptyPrompt.localizedDescription
                : AIPlanEditError.missingAPIKey.localizedDescription
            return
        }
        isGenerating = true
        defer { isGenerating = false }
        do {
            let apiKey = try await resolveAPIKey()
            let response = try await editingService.generatePlanEdit(
                apiKey: apiKey,
                model: settingsManager.chatModel,
                prompt: prompt,
                programName: programEditorViewModel.programName,
                programType: programEditorViewModel.programType,
                selectedExercises: programEditorViewModel.selectedExercises,
                availableExerciseNames: programEditorViewModel.aiAvailableExerciseNames
            )
            preview = try await programEditorViewModel.makeAIPlanPreview(from: response)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleRecording() async {
        if isRecording {
            await stopAndTranscribe()
        } else {
            await startRecording()
        }
    }

    func applyPreview() async {
        guard let preview else { return }
        await programEditorViewModel.applyAIPlanPreview(preview)
        if let error = programEditorViewModel.errorMessage {
            errorMessage = error
            return
        }
        didApply = true
    }

    private func startRecording() async {
        do {
            let allowed = await audioRecorder.requestPermission()
            guard allowed else {
                errorMessage = String(localized: "ai_microphone_permission_error")
                return
            }
            try audioRecorder.start()
            isRecording = true
            recordingStartedAt = Date()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func stopAndTranscribe() async {
        isRecording = false
        recordingStartedAt = nil
        guard let url = audioRecorder.stop() else { return }
        isTranscribing = true
        defer {
            isTranscribing = false
            try? FileManager.default.removeItem(at: url)
        }
        do {
            let apiKey = try await resolveAPIKey()
            let text = try await editingService.transcribe(
                apiKey: apiKey,
                model: settingsManager.voiceModel,
                audioFileURL: url
            )
            transcript = text
            if prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                prompt = text
            } else {
                prompt += "\n\(text)"
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resolveAPIKey() async throws -> String {
        guard let key = try settingsManager.apiKey(), !key.isEmpty else {
            throw AIPlanEditError.missingAPIKey
        }
        return key
    }
}
