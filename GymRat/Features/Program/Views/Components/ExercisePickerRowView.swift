import SwiftUI

struct ExercisePickerRowView: View {
    private let seed: ExerciseRepo.ExerciseSeed
    private let selectedExercise: WorkoutExercise?
    private let selectionNumber: Int?
    private let isEditing: Bool
    private let onToggle: (ExerciseRepo.ExerciseSeed) -> Void
    private let onClearHistory: (WorkoutExercise) -> Void

    init(
        seed: ExerciseRepo.ExerciseSeed,
        selectedExercise: WorkoutExercise?,
        selectionNumber: Int?,
        isEditing: Bool,
        onToggle: @escaping (ExerciseRepo.ExerciseSeed) -> Void,
        onClearHistory: @escaping (WorkoutExercise) -> Void
    ) {
        self.seed = seed
        self.selectedExercise = selectedExercise
        self.selectionNumber = selectionNumber
        self.isEditing = isEditing
        self.onToggle = onToggle
        self.onClearHistory = onClearHistory
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        onToggle(seed)
                    }
                } label: {
                    HStack {
                        Text(seed.name)
                        Spacer()
                        selectionIndicator
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)

                if isEditing, let exercise = selectedExercise {
                    Button {
                        onClearHistory(exercise)
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .padding(6)
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.secondary)
                    .accessibilityLabel(Text("clear_exercise_history"))
                }
            }
        }
    }


    @ViewBuilder
    private var selectionIndicator: some View {
        if let number = selectionNumber {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                Text("\(number)")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.white)
            }
            .frame(width: 22, height: 22)
        } else if selectedExercise != nil {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentColor)
        }
    }
}
