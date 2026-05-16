import SwiftUI
struct ExerciseSetsList: View {
    private let viewModel: ExerciseRowViewModel
    @FocusState.Binding private var focusedField: ExerciseField?
    private let weightKeyboard: UIKeyboardType
    private let durationKeyboard: UIKeyboardType
    private let durationFont: Font
    private let columnSpacing: CGFloat
    private let rowSpacing: CGFloat
    private let statBoxWidth: CGFloat
    init(
        viewModel: ExerciseRowViewModel,
        focusedField: FocusState<ExerciseField?>.Binding,
        weightKeyboard: UIKeyboardType,
        durationKeyboard: UIKeyboardType,
        durationFont: Font,
        columnSpacing: CGFloat,
        rowSpacing: CGFloat,
        statBoxWidth: CGFloat
    ) {
        self.viewModel = viewModel
        self._focusedField = focusedField
        self.weightKeyboard = weightKeyboard
        self.durationKeyboard = durationKeyboard
        self.durationFont = durationFont
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        self.statBoxWidth = statBoxWidth
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: rowSpacing) {
                ForEach(0..<viewModel.setsCount, id: \.self) { index in
                    SetRowView(
                        columns: viewModel.setRowColumns,
                        index: index,
                        previousReps: viewModel.previousRepsText(at: index),
                        previousWeight: viewModel.previousWeightText(at: index),
                        previousDuration: viewModel.previousDurationText(at: index),
                        repsPlaceholder: viewModel.repsPlaceholder,
                        weightPlaceholder: viewModel.weightPlaceholder,
                        weightKeyboard: weightKeyboard,
                        durationPlaceholder: viewModel.durationPlaceholder,
                        durationKeyboard: durationKeyboard,
                        durationFont: durationFont,
                        boxWidth: statBoxWidth,
                        currentReps: repsBinding(index: index),
                        currentWeight: weightBinding(index: index),
                        currentDuration: durationBinding(index: index),
                        programExerciseId: viewModel.programExercise.id,
                        focusedField: $focusedField,
                        columnSpacing: columnSpacing
                    )
                }
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 2)
        }
    }
    private func repsBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.repsText(at: index) },
            set: { viewModel.updateRepsText($0, index: index) }
        )
    }
    private func weightBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.weightText(at: index) },
            set: { viewModel.updateWeightText($0, index: index) }
        )
    }
    private func durationBinding(index: Int) -> Binding<String> {
        Binding(
            get: { viewModel.durationText(at: index) },
            set: { viewModel.updateDurationText($0, index: index) }
        )
    }
}
