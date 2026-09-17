import SwiftUI
import UniformTypeIdentifiers

struct ProgramCard: View {
    let program: ProgramSnapshot
    let selectedDate: Date
    let onEdit: ((ProgramSnapshot) -> Void)?
    let onDelete: ((ProgramSnapshot) -> Void)?

    /// Local order while a row is being dragged; follows `program.exercises` otherwise.
    @State private var exercises: [WorkoutExerciseSnapshot]
    @State private var draggingExercise: WorkoutExerciseSnapshot?
    @FocusState private var focusedField: ExerciseField?
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.viewModelFactory) private var viewModelFactory

    init(
        program: ProgramSnapshot,
        selectedDate: Date,
        onEdit: ((ProgramSnapshot) -> Void)?,
        onDelete: ((ProgramSnapshot) -> Void)?
    ) {
        self.program = program
        self.selectedDate = selectedDate
        self.onEdit = onEdit
        self.onDelete = onDelete
        _exercises = State(initialValue: program.exercises)
    }

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

            ForEach(exercises) { exercise in
                ExerciseRow(
                    viewModel: viewModelFactory.makeExerciseRowViewModel(
                        programExercise: exercise,
                        selectedDate: selectedDate
                    ),
                    programID: program.id,
                    selectedDate: selectedDate,
                    exercises: $exercises,
                    draggingExercise: $draggingExercise,
                    focusedField: $focusedField
                )
            }
        }
        .onChange(of: program.exercises) { _, updated in
            exercises = updated
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(programColor, lineWidth: 2)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
