import SwiftUI

struct SetRowView: View {
    let columns: [ProgramTableExerciseRowViewModel.SetRowColumn]
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
    let boxWidth: CGFloat
    @Binding var currentReps: String
    @Binding var currentWeight: String
    @Binding var currentDuration: String
    let programExerciseId: UUID
    @FocusState.Binding var focusedField: ProgramTableFocusField?
    let columnSpacing: CGFloat

    var body: some View {
        HStack(spacing: columnSpacing) {
            ForEach(columns) { column in
                SetRowColumnView(
                    column: column,
                    index: index,
                    previousReps: previousReps,
                    previousWeight: previousWeight,
                    previousDuration: previousDuration,
                    repsPlaceholder: repsPlaceholder,
                    weightPlaceholder: weightPlaceholder,
                    weightKeyboard: weightKeyboard,
                    durationPlaceholder: durationPlaceholder,
                    durationKeyboard: durationKeyboard,
                    durationFont: durationFont,
                    boxWidth: boxWidth,
                    currentReps: $currentReps,
                    currentWeight: $currentWeight,
                    currentDuration: $currentDuration,
                    programExerciseId: programExerciseId,
                    focusedField: $focusedField
                )
            }
        }
    }
}
