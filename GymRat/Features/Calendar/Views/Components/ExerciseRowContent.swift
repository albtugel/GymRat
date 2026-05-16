import SwiftUI

struct ExerciseLogRowRootView: View {
    private let viewModel: ExerciseRowViewModel
    @FocusState.Binding private var focusedField: ExerciseField?
    private let accentColor: Color

    init(
        viewModel: ExerciseRowViewModel,
        focusedField: FocusState<ExerciseField?>.Binding,
        accentColor: Color
    ) {
        self.viewModel = viewModel
        self._focusedField = focusedField
        self.accentColor = accentColor
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ExerciseRowHeader(
                name: viewModel.programExercise.exercise.name,
                isSharedHistory: viewModel.programExercise.sharedHistory,
                selectionIndex: viewModel.programExercise.selectionIndex,
                accentColor: accentColor,
                seed: viewModel.seed
            )

            ExerciseSetsSection(
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
