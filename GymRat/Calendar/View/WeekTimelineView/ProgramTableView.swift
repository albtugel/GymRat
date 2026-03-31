import SwiftUI
import UniformTypeIdentifiers

struct ProgramTableView: View {
    let program: ProgramModel
    let selectedDate: Date

    @State private var draggingExercise: ProgramExercise?
    @FocusState private var focusedField: ProgramTableFocusField?
    @EnvironmentObject var themeManager: ThemeManager

    var programColor: Color {
        if let hex = program.colorHex, !hex.isEmpty {
            return Color(hex: hex) ?? themeManager.accentColor
        }
        return themeManager.accentColor
    }

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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(programColor, lineWidth: 2)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum ProgramTableFocusField: Hashable {
    case sets(UUID)
    case reps(UUID, Int)
    case weight(UUID, Int)
    case duration(UUID, Int)
}
