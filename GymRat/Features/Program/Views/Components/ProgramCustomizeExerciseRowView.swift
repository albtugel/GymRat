import SwiftUI

struct ProgramCustomizeExerciseRowView: View {
    private let seed: ExerciseStore.ExerciseSeed
    private let selectedExercise: ProgramExercise?
    private let selectionNumber: Int?
    private let isEditing: Bool
    private let onToggle: (ExerciseStore.ExerciseSeed) -> Void
    private let onClearHistory: (ProgramExercise) -> Void

    init(
        seed: ExerciseStore.ExerciseSeed,
        selectedExercise: ProgramExercise?,
        selectionNumber: Int?,
        isEditing: Bool,
        onToggle: @escaping (ExerciseStore.ExerciseSeed) -> Void,
        onClearHistory: @escaping (ProgramExercise) -> Void
    ) {
        self.seed = seed
        self.selectedExercise = selectedExercise
        self.selectionNumber = selectionNumber
        self.isEditing = isEditing
        self.onToggle = onToggle
        self.onClearHistory = onClearHistory
    }

    // MARK: - Body
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

    // MARK: - Subviews
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
