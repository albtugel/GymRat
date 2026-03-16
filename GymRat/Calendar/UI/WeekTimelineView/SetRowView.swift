import SwiftUI

struct SetRowView: View {
    let index: Int
    let previousReps: String
    let previousWeight: String
    let previousDuration: String
    let repsPlaceholder: String
    let weightPlaceholder: String
    let weightKeyboard: UIKeyboardType
    let durationPlaceholder: String
    let durationKeyboard: UIKeyboardType
    let durationFont: Font
    let showsDuration: Bool
    let showsWeight: Bool
    let boxWidth: CGFloat
    @Binding var currentReps: String
    @Binding var currentWeight: String
    @Binding var currentDuration: String
    let programExerciseId: UUID
    @FocusState.Binding var focusedField: ProgramTableFocusField?
    let columnSpacing: CGFloat

    var body: some View {
        HStack(spacing: columnSpacing) {
            StatBoxView(
                text: .constant(previousReps),
                placeholder: repsPlaceholder,
                isAccent: false,
                keyboard: .numberPad,
                font: .footnote,
                editable: false,
                focusedField: nil,
                focusedFieldBinding: $focusedField,
                boxWidth: boxWidth,
                boxHeight: 36
            )

            if showsWeight {
                StatBoxView(
                    text: .constant(previousWeight),
                    placeholder: weightPlaceholder,
                    isAccent: false,
                    keyboard: weightKeyboard,
                    font: .subheadline,
                    editable: false,
                    focusedField: nil,
                    focusedFieldBinding: $focusedField,
                    boxWidth: boxWidth,
                    boxHeight: 36
                )
            }

            if showsDuration {
                StatBoxView(
                    text: .constant(previousDuration),
                    placeholder: durationPlaceholder,
                    isAccent: false,
                    keyboard: durationKeyboard,
                    font: durationFont,
                    editable: false,
                    focusedField: nil,
                    focusedFieldBinding: $focusedField,
                    boxWidth: boxWidth,
                    boxHeight: 36
                )
            }

            StatBoxView(
                text: $currentReps,
                placeholder: repsPlaceholder,
                isAccent: true,
                keyboard: .numberPad,
                font: .footnote,
                editable: true,
                focusedField: .reps(programExerciseId, index),
                focusedFieldBinding: $focusedField,
                boxWidth: boxWidth,
                boxHeight: 36
            )

            if showsWeight {
                StatBoxView(
                    text: $currentWeight,
                    placeholder: weightPlaceholder,
                    isAccent: true,
                    keyboard: weightKeyboard,
                    font: .subheadline,
                    editable: true,
                    focusedField: .weight(programExerciseId, index),
                    focusedFieldBinding: $focusedField,
                    boxWidth: boxWidth,
                    boxHeight: 36
                )
            }

            if showsDuration {
                StatBoxView(
                    text: $currentDuration,
                    placeholder: durationPlaceholder,
                    isAccent: true,
                    keyboard: durationKeyboard,
                    font: durationFont,
                    editable: true,
                    focusedField: .duration(programExerciseId, index),
                    focusedFieldBinding: $focusedField,
                    boxWidth: boxWidth,
                    boxHeight: 36
                )
            }
        }
    }
}
