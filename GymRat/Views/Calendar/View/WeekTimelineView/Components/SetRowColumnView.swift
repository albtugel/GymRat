import SwiftUI

struct SetRowColumnView: View {
    private let column: ProgramTableExerciseRowViewModel.SetRowColumn
    private let index: Int
    private let previousReps: String
    private let previousWeight: String
    private let previousDuration: String
    private let repsPlaceholder: String
    private let weightPlaceholder: String
    private let weightKeyboard: UIKeyboardType
    private let durationPlaceholder: String
    private let durationKeyboard: UIKeyboardType
    private let durationFont: Font
    private let boxWidth: CGFloat
    @Binding private var currentReps: String
    @Binding private var currentWeight: String
    @Binding private var currentDuration: String
    private let programExerciseId: UUID
    @FocusState.Binding private var focusedField: ProgramTableFocusField?

    init(
        column: ProgramTableExerciseRowViewModel.SetRowColumn,
        index: Int,
        previousReps: String,
        previousWeight: String,
        previousDuration: String,
        repsPlaceholder: String,
        weightPlaceholder: String,
        weightKeyboard: UIKeyboardType,
        durationPlaceholder: String,
        durationKeyboard: UIKeyboardType,
        durationFont: Font,
        boxWidth: CGFloat,
        currentReps: Binding<String>,
        currentWeight: Binding<String>,
        currentDuration: Binding<String>,
        programExerciseId: UUID,
        focusedField: FocusState<ProgramTableFocusField?>.Binding
    ) {
        self.column = column
        self.index = index
        self.previousReps = previousReps
        self.previousWeight = previousWeight
        self.previousDuration = previousDuration
        self.repsPlaceholder = repsPlaceholder
        self.weightPlaceholder = weightPlaceholder
        self.weightKeyboard = weightKeyboard
        self.durationPlaceholder = durationPlaceholder
        self.durationKeyboard = durationKeyboard
        self.durationFont = durationFont
        self.boxWidth = boxWidth
        self._currentReps = currentReps
        self._currentWeight = currentWeight
        self._currentDuration = currentDuration
        self.programExerciseId = programExerciseId
        self._focusedField = focusedField
    }

    var body: some View {
        switch column {
        case .previousReps:
            SetRowStatBoxView(
                text: .constant(previousReps),
                placeholder: repsPlaceholder,
                isAccent: false,
                keyboard: .numberPad,
                font: .footnote,
                editable: false,
                focusedField: nil,
                focusedFieldBinding: $focusedField,
                boxWidth: boxWidth
            )
        case .previousWeight:
            SetRowStatBoxView(
                text: .constant(previousWeight),
                placeholder: weightPlaceholder,
                isAccent: false,
                keyboard: weightKeyboard,
                font: .subheadline,
                editable: false,
                focusedField: nil,
                focusedFieldBinding: $focusedField,
                boxWidth: boxWidth
            )
        case .previousDuration:
            SetRowStatBoxView(
                text: .constant(previousDuration),
                placeholder: durationPlaceholder,
                isAccent: false,
                keyboard: durationKeyboard,
                font: durationFont,
                editable: false,
                focusedField: nil,
                focusedFieldBinding: $focusedField,
                boxWidth: boxWidth
            )
        case .currentReps:
            SetRowStatBoxView(
                text: $currentReps,
                placeholder: repsPlaceholder,
                isAccent: true,
                keyboard: .numberPad,
                font: .footnote,
                editable: true,
                focusedField: .reps(programExerciseId, index),
                focusedFieldBinding: $focusedField,
                boxWidth: boxWidth
            )
        case .currentWeight:
            SetRowStatBoxView(
                text: $currentWeight,
                placeholder: weightPlaceholder,
                isAccent: true,
                keyboard: weightKeyboard,
                font: .subheadline,
                editable: true,
                focusedField: .weight(programExerciseId, index),
                focusedFieldBinding: $focusedField,
                boxWidth: boxWidth
            )
        case .currentDuration:
            SetRowStatBoxView(
                text: $currentDuration,
                placeholder: durationPlaceholder,
                isAccent: true,
                keyboard: durationKeyboard,
                font: durationFont,
                editable: true,
                focusedField: .duration(programExerciseId, index),
                focusedFieldBinding: $focusedField,
                boxWidth: boxWidth
            )
        }
    }
}
