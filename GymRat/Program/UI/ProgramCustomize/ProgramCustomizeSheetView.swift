import SwiftUI
import SwiftData

struct ProgramCustomizeSheetView: View {

    let mode: ProgramCustomizeMode
    let context: ModelContext?
    let baseProgram: ProgramModel

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var programManager: ProgramManager

    @State private var name: String
    @State private var details: String
    @State private var programType: ProgramType
    @State private var selectedExercises: Set<ExerciseModel>

    @Query private var allExercises: [ExerciseModel]

    init(
        mode: ProgramCustomizeMode,
        context: ModelContext? = nil,
        baseProgram: ProgramModel
    ) {
        self.mode = mode
        self.context = context
        self.baseProgram = baseProgram

        _name = State(initialValue: baseProgram.name)
        _details = State(initialValue: baseProgram.details)
        _programType = State(initialValue: baseProgram.type)
        _selectedExercises = State(initialValue: Set(baseProgram.exercises))
    }

    var body: some View {
        ProgramCustomizeContentView(
            baseProgram: .constant(baseProgram),
            name: $name,
            details: $details,
            weekdays: .constant([]), // UI не меняем
            programType: $programType,
            selectedExercises: $selectedExercises,
            filteredExercises: filteredExercises,
            mode: mode,
            saveAction: save
        )
    }

    private var filteredExercises: [ExerciseModel] {
        allExercises.filter { programType.allows($0) }
    }

    private func save() {
        baseProgram.name = name
        baseProgram.details = details
        baseProgram.type = programType
        baseProgram.exercises = Array(selectedExercises)

        if mode == .create {
            context?.insert(baseProgram)
        }

        dismiss()
    }
}
