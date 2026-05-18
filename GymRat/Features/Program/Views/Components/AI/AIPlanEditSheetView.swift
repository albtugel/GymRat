import SwiftUI

struct AIPlanEditSheetView: View {
    @State private var viewModel: AIPlanEditViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AIPlanEditViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                apiKeySection
                promptSection
                transcriptSection
                previewSection
            }
            .navigationTitle("ai_edit_title")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel_button") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("apply_button") {
                        Task { await viewModel.applyPreview() }
                    }
                    .disabled(viewModel.preview == nil)
                }
            }
            .safeAreaInset(edge: .bottom) {
                generateBar
            }
            .alert("ai_error_title", isPresented: errorBinding) {
                Button("ok_button") { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: viewModel.didApply) { _, didApply in
                if didApply {
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private var apiKeySection: some View {
        Section {
            if viewModel.hasStoredAPIKey {
                AIAPIKeyStatusRow()
                    .accessibilityIdentifier("aiInlineAPIKeySavedLabel")
            } else {
                SecureField("ai_api_key_placeholder", text: apiKeyBinding)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("aiInlineAPIKeyField")

                Button {
                    Task { await viewModel.verifyAPIKey() }
                } label: {
                    if viewModel.isVerifyingAPIKey {
                        HStack {
                            ProgressView()
                            Text("ai_verifying_key_button")
                        }
                    } else {
                        Text("ai_verify_save_key_button")
                    }
                }
                .disabled(!viewModel.canVerifyAPIKey)
                .accessibilityIdentifier("aiInlineVerifyKeyButton")

                if let apiKeyErrorMessage = viewModel.apiKeyErrorMessage {
                    Label(apiKeyErrorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("aiInlineAPIKeyErrorLabel")
                }
            }
        } header: {
            Text("ai_api_setup_section")
        } footer: {
            Text(viewModel.hasStoredAPIKey ? "ai_privacy_note" : "ai_inline_api_key_footer")
        }
    }

    private var promptSection: some View {
        Section("ai_prompt_section") {
            ZStack(alignment: .topLeading) {
                if viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("ai_prompt_examples")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.horizontal, 5)
                        .allowsHitTesting(false)
                }

                TextEditor(text: promptBinding)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier("aiPromptEditor")
            }

            Button {
                Task { await viewModel.toggleRecording() }
            } label: {
                HStack {
                    Label(
                        viewModel.isRecording ? "ai_stop_recording_button" : "ai_record_button",
                        systemImage: viewModel.isRecording ? "stop.circle.fill" : "mic.circle"
                    )
                    Spacer()
                    recordingDurationView
                }
            }
            .disabled(!viewModel.canRecord)
            .accessibilityIdentifier("aiRecordButton")

            if viewModel.isTranscribing {
                ProgressView("ai_transcribing_label")
            }
        }
    }

    @ViewBuilder
    private var transcriptSection: some View {
        if !viewModel.transcript.isEmpty {
            Section("ai_transcript_section") {
                Text(viewModel.transcript)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var previewSection: some View {
        if let preview = viewModel.preview {
            Section("ai_preview_section") {
                if let name = preview.programName {
                    LabeledContent("program_name_placeholder", value: name)
                }

                ForEach(preview.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(exercise.resolvedName)
                            Spacer()
                            changeBadge(for: exercise.changeKind)
                        }
                        Text(String(format: String(localized: "ai_preview_sets_reps_format"), exercise.sets, exercise.reps))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        if exercise.isUnknown {
                            Text(String(format: String(localized: "ai_unknown_exercise_format"), exercise.resolvedName))
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                ForEach(preview.removedExerciseNames, id: \.self) { name in
                    HStack {
                        Text(name)
                            .strikethrough()
                            .foregroundStyle(.secondary)
                        Spacer()
                        changeBadge(textKey: "ai_change_removed", color: .red)
                    }
                }

                if preview.hasUnknownExercises {
                    Label("ai_unknown_exercises_note", systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var generateBar: some View {
        Button {
            Task { await viewModel.generatePreview() }
        } label: {
            if viewModel.isGenerating {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Label("ai_generate_button", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("aiGenerateButton")
        .padding()
        .background(.bar)
        .disabled(!viewModel.canGenerate)
    }

    @ViewBuilder
    private var recordingDurationView: some View {
        if viewModel.isRecording, let startedAt = viewModel.recordingStartedAt {
            TimelineView(.periodic(from: startedAt, by: 1)) { context in
                Text(recordingDuration(from: startedAt, to: context.date))
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func changeBadge(for kind: AIPlanEditPreview.ChangeKind) -> some View {
        switch kind {
        case .added:
            changeBadge(textKey: "ai_change_added", color: .green)
        case .changed:
            changeBadge(textKey: "ai_change_changed", color: .orange)
        case .unchanged:
            changeBadge(textKey: "ai_change_unchanged", color: .secondary)
        case .custom:
            changeBadge(textKey: "ai_change_custom", color: .blue)
        }
    }

    private func changeBadge(textKey: LocalizedStringKey, color: Color) -> some View {
        Text(textKey)
            .font(.caption2.weight(.semibold))
            .textCase(.uppercase)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.12), in: Capsule())
    }

    private func recordingDuration(from start: Date, to end: Date) -> String {
        let seconds = max(0, Int(end.timeIntervalSince(start)))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private var promptBinding: Binding<String> {
        Binding(
            get: { viewModel.prompt },
            set: { viewModel.updatePrompt($0) }
        )
    }

    private var apiKeyBinding: Binding<String> {
        Binding(
            get: { viewModel.apiKeyInput },
            set: { viewModel.updateAPIKeyInput($0) }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }
}
