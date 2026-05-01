import SwiftUI
import UniformTypeIdentifiers

struct ProgramTableView: View {
    let program: ProgramModel
    let selectedDate: Date
    let onEdit: ((ProgramModel) -> Void)?

    @State private var draggingExercise: ProgramExercise?
    @FocusState private var focusedField: ProgramTableFocusField?
    @Environment(ThemeManager.self) private var themeManager

    private var programColor: Color {
        if let hex = program.colorHex, !hex.isEmpty {
            return Color(hex: hex) ?? themeManager.accentColor
        }
        return themeManager.accentColor
    }

    var body: some View {
        VStack(spacing: 8) {
            ProgramTableTitleCard(name: program.name, onEdit: {
                onEdit?(program)
            })

            ForEach(program.exercises) { exercise in
                ProgramTableExerciseRowView(
                    viewModel: AppDependencies.shared.makeProgramTableExerciseRowViewModel(
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
