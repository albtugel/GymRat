import SwiftUI

struct ProgramCustomizeSheetView: View {
    @State private var viewModel: ProgramCustomizeViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    @FocusState private var nameFieldIsFocused: Bool

    init(viewModel: ProgramCustomizeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ProgramCustomizeContentView(
            viewModel: viewModel,
            nameFieldIsFocused: $nameFieldIsFocused,
            accentColor: themeManager.accentColor,
            onCancel: { dismiss() }
        )
        .safeAreaInset(edge: .bottom) {
            ProgramCustomizeSaveButton(
                accentColor: themeManager.accentColor,
                onSave: { Task { await viewModel.saveProgram() } }
            )
        }
        .task {
            await viewModel.seedExercisesIfNeeded()
            await viewModel.loadData()
        }
        .onChange(of: viewModel.didSave) { _, didSave in
            if didSave {
                dismiss()
            }
        }
        .modifier(ProgramCustomizeAlertsModifier(viewModel: viewModel))
    }
}
