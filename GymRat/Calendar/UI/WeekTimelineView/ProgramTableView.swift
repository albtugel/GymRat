import SwiftUI
import UniformTypeIdentifiers

struct ProgramTableView: View {
    let program: ProgramModel
    let selectedDate: Date

    @State private var draggingExercise: ProgramExercise?
    @FocusState private var focusedField: ProgramTableFocusField?

    var body: some View {
        VStack(spacing: 8) {
            ProgramTableTitleCard(name: program.name)

            ForEach(program.exercises) { exercise in
                ProgramTableExerciseRowView(
                    programExercise: exercise,
                    program: program,
                    selectedDate: selectedDate,
                    draggingExercise: $draggingExercise,
                    focusedField: $focusedField
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum ProgramTableFocusField: Hashable {
    case sets(UUID)
    case reps(UUID, Int)
    case weight(UUID, Int)
    case duration(UUID, Int)
}
