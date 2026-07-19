import SwiftUI
import UniformTypeIdentifiers

struct ProgramCard: View {
    let program: Program
    let selectedDate: Date
    let onEdit: ((Program) -> Void)?
    let onDelete: ((Program) -> Void)?

    @State private var draggingExercise: WorkoutExercise?
    @FocusState private var focusedField: ExerciseField?
    @Environment(ThemeStore.self) private var themeStore

    private var programColor: Color {
        if let hex = program.colorHex, !hex.isEmpty {
            return Color(hex: hex) ?? themeStore.accentColor
        }
        return themeStore.accentColor
    }

    var body: some View {
        VStack(spacing: 8) {
            ProgramHeader(
                name: program.name,
                onEdit: onEdit.map { handler in { handler(program) } },
                onDelete: onDelete.map { handler in { handler(program) } }
            )

            ForEach(program.exercises) { exercise in
                ExerciseRow(
                    viewModel: Dependencies.shared.makeExerciseRowViewModel(
                        programExercise: exercise,
                        selectedDate: selectedDate
                    ),
                    program: program,
                    selectedDate: selectedDate,
                    draggingExercise: $draggingExercise,
                    focusedField: $focusedField
                )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(programColor, lineWidth: 2)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
