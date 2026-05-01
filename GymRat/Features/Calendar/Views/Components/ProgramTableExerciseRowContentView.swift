import SwiftUI

struct ProgramTableExerciseRowContentView: View {
    private let viewModel: ProgramTableExerciseRowViewModel
    @FocusState.Binding private var focusedField: ProgramTableFocusField?
    private let accentColor: Color

    init(
        viewModel: ProgramTableExerciseRowViewModel,
        focusedField: FocusState<ProgramTableFocusField?>.Binding,
        accentColor: Color
    ) {
        self.viewModel = viewModel
        self._focusedField = focusedField
        self.accentColor = accentColor
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgramTableExerciseRowHeaderView(
                name: viewModel.programExercise.exercise.name,
                isSharedHistory: viewModel.programExercise.sharedHistory,
                selectionIndex: viewModel.programExercise.selectionIndex,
                accentColor: accentColor,
                seed: viewModel.seed
            )

            ProgramTableExerciseRowSetsSectionView(
                viewModel: viewModel,
                focusedField: $focusedField
            )
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
