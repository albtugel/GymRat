import SwiftUI

struct ExerciseSetsContent: View {
    private let viewModel: ExerciseRowViewModel
    @FocusState.Binding private var focusedField: ExerciseField?
    private let setsCountText: Binding<String>
    private let weightKeyboard: UIKeyboardType
    private let durationKeyboard: UIKeyboardType
    private let durationFont: Font
    private let columnSpacing: CGFloat
    private let rowSpacing: CGFloat
    private let statBoxWidth: CGFloat

    init(
        viewModel: ExerciseRowViewModel,
        focusedField: FocusState<ExerciseField?>.Binding,
        setsCountText: Binding<String>,
        weightKeyboard: UIKeyboardType,
        durationKeyboard: UIKeyboardType,
        durationFont: Font,
        columnSpacing: CGFloat,
        rowSpacing: CGFloat,
        statBoxWidth: CGFloat
    ) {
        self.viewModel = viewModel
        self._focusedField = focusedField
        self.setsCountText = setsCountText
        self.weightKeyboard = weightKeyboard
        self.durationKeyboard = durationKeyboard
        self.durationFont = durationFont
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        self.statBoxWidth = statBoxWidth
    }


    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SetsField(
                title: viewModel.setsTitle,
                setsText: setsCountText,
                focusedField: .sets(viewModel.programExercise.id),
                focusedFieldBinding: $focusedField
            )

            ExerciseSetsList(
                viewModel: viewModel,
                focusedField: $focusedField,
                weightKeyboard: weightKeyboard,
                durationKeyboard: durationKeyboard,
                durationFont: durationFont,
                columnSpacing: columnSpacing,
                rowSpacing: rowSpacing,
                statBoxWidth: statBoxWidth
            )
        }
    }
}
