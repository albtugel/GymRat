import SwiftUI

struct ProgramEditorView: View {
    @State private var viewModel: ProgramEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore
    @FocusState private var nameFieldIsFocused: Bool

    init(viewModel: ProgramEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ProgramEditorContent(
            viewModel: viewModel,
            nameFieldIsFocused: $nameFieldIsFocused,
            accentColor: themeStore.accentColor,
            onCancel: { dismiss() }
        )
        .safeAreaInset(edge: .bottom) {
            SaveProgramButton(
                accentColor: themeStore.accentColor,
                onSave: { Task { await viewModel.save() } }
            )
        }
        .task {
            await viewModel.seedExercisesIfNeeded()
            await viewModel.load()
        }
        .onChange(of: viewModel.didSave) { _, didSave in
            if didSave {
                dismiss()
            }
        }
        .modifier(ProgramAlerts(viewModel: viewModel))
    }
}
