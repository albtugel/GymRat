import SwiftUI

struct ProgramCustomizeContentView: View {
    private let viewModel: ProgramCustomizeViewModel
    @FocusState.Binding private var nameFieldIsFocused: Bool
    private let accentColor: Color
    private let onCancel: () -> Void

    init(
        viewModel: ProgramCustomizeViewModel,
        nameFieldIsFocused: FocusState<Bool>.Binding,
        accentColor: Color,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self._nameFieldIsFocused = nameFieldIsFocused
        self.accentColor = accentColor
        self.onCancel = onCancel
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                ProgramCustomizeInfoSectionView(
                    programName: viewModel.programName,
                    programColor: programColor,
                    nameFieldIsFocused: $nameFieldIsFocused,
                    onProgramNameChange: viewModel.updateProgramName,
                    onProgramColorChange: { viewModel.updateProgramColorHex($0.toHex()) },
                    onNameFieldFocusChange: viewModel.handleNameFieldFocusChange
                )

                ProgramCustomizeDaysSectionView(viewModel: viewModel)

                ProgramCustomizeExercisesSectionView(viewModel: viewModel)
            }
            .safeAreaPadding(.bottom, 50)
            .navigationTitle(viewModel.programTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel_button") {
                        onCancel()
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private var programColor: Color {
        if !viewModel.programColorHex.isEmpty, let color = Color(hex: viewModel.programColorHex) {
            return color
        }
        return accentColor
    }
}
