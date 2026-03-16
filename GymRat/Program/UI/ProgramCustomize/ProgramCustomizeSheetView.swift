import SwiftUI
import SwiftData

struct ProgramCustomizeSheetView: View {

    let mode: ProgramCustomizeMode // .create или .edit
    @State var programManager = ProgramManager.shared
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    @State var program: ProgramModel
    @State var selectedExercises: [ProgramExercise] = []
    @State var selectedWeekdays: Set<ProgramWeekDay> = []
    @State var programName: String = ""
    @FocusState var nameFieldIsFocused: Bool
    @State var isSaving = false

    private var filteredExerciseSeeds: [ExerciseStore.ExerciseSeed] {
        ExerciseStore.shared.seeds.filter { program.type.allows($0.category) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    ProgramCustomizeInfoSectionView(
                        programName: $programName,
                        nameFieldIsFocused: $nameFieldIsFocused
                    )

                    ProgramCustomizeDaysSectionView(selectedWeekdays: $selectedWeekdays)

                    ProgramCustomizeExercisesSectionView(
                        exerciseSeeds: filteredExerciseSeeds,
                        selectedExercises: $selectedExercises,
                        isEditing: mode == .edit,
                        onToggle: toggleExercise
                    )
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("ok_button") { nameFieldIsFocused = false }
                    }
                }

                // --- Save Button ---
                Button(action: saveProgram) {
                    Text("save_button")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationTitle(program.type.title)
        .onAppear {
            ExerciseSeeder.seedIfNeeded(context: context)
            programName = program.name
            selectedExercises = program.exercises
            selectedWeekdays = program.weekdays
        }
    }
}
