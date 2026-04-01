import SwiftUI
import SwiftData

struct ProgramCustomizeSheetView: View {
    let mode: ProgramCustomizeMode
    @State var programManager = ProgramManager.shared
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    @State var program: ProgramModel
    @State var selectedExercises: [ProgramExercise] = []
    @State var selectedWeekdays: Set<ProgramWeekDay> = []
    @State var programName: String = ""
    @State var programColor: Color = .accentColor
    @FocusState var nameFieldIsFocused: Bool
    @State var isSaving = false
    @State var showSharedHistoryAlert = false
    @State var showNoSharedExerciseAlert = false
    @State var showWeekdaysRequiredAlert = false
    @State var pendingSeed: ExerciseStore.ExerciseSeed?

    @Query private var customExercises: [ExerciseModel]
    @EnvironmentObject var themeManager: ThemeManager
    @Query var allPrograms: [ProgramModel]

    init(mode: ProgramCustomizeMode, program: ProgramModel) {
        self.mode = mode
        _program = State(initialValue: program)
        _selectedExercises = State(initialValue: program.exercises)
        _selectedWeekdays = State(initialValue: program.weekdays)
        _programName = State(initialValue: program.name)
    }

    private var filteredExerciseSeeds: [ExerciseStore.ExerciseSeed] {
        let builtIn = ExerciseStore.shared.seeds.filter { program.type.allows($0.category) }
        let custom = customExercises
            .filter { $0.isCustom && program.type.allows($0.category) }
            .map {
                let inputType: ExerciseInputType = $0.category == .cardio ? .cardioDistance : .strength
                return ExerciseStore.ExerciseSeed(
                    name: $0.name,
                    category: $0.category,
                    muscles: [],
                    exerciseDBKey: nil,
                    inputType: inputType
                )
            }
        return builtIn + custom
    }

    var body: some View {
        NavigationStack {
            Form {
                ProgramCustomizeInfoSectionView(
                    programName: $programName,
                    programColor: $programColor,
                    nameFieldIsFocused: $nameFieldIsFocused
                )

                ProgramCustomizeDaysSectionView(selectedWeekdays: $selectedWeekdays)

                ProgramCustomizeExercisesSectionView(
                    exerciseSeeds: filteredExerciseSeeds,
                    programType: program.type,
                    selectedExercises: $selectedExercises,
                    isEditing: mode == .edit,
                    onToggle: toggleExercise,
                    onCreateCustom: createCustomExercise
                )
            }
            .safeAreaPadding(.bottom, 50)
            .navigationTitle(program.type.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel_button") {
                        dismiss()
                    }
                }
            }
            .alert(LocalizedStringKey(AppAlerts.SharedHistory.title), isPresented: $showSharedHistoryAlert) {
                Button("shared_history_button") {
                    addPendingExercise(sharedHistory: true)
                }
                Button("separate_history_button") {
                    addPendingExercise(sharedHistory: false)
                }
                Button("cancel_button", role: .cancel) {
                    pendingSeed = nil
                }
            } message: {
                let name = pendingSeed?.name ?? ""
                Text(String(format: String(localized: "shared_history_alert_message"), name))
            }
            .alert(LocalizedStringKey(AppAlerts.NoSharedExercise.title), isPresented: $showNoSharedExerciseAlert) {
                Button("ok_button", role: .cancel) { }
            } message: {
                Text(LocalizedStringKey(AppAlerts.NoSharedExercise.message))
            }
            .alert(LocalizedStringKey(AppAlerts.ProgramDaysRequired.title), isPresented: $showWeekdaysRequiredAlert) {
                Button("ok_button", role: .cancel) { }
            } message: {
                Text(LocalizedStringKey(AppAlerts.ProgramDaysRequired.message))
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: saveProgram) {
                Text("save_button")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.accentColor)
                    )
            }
            .contentShape(Rectangle())
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .onAppear {
            ExerciseSeeder.seedIfNeeded(context: context)
            programName = program.name
            if let hex = program.colorHex, !hex.isEmpty {
                programColor = Color(hex: hex) ?? themeManager.accentColor
            } else {
                programColor = themeManager.accentColor
            }
            selectedExercises = program.exercises
            selectedWeekdays = program.weekdays
        }
    }

    private func createCustomExercise(name: String, category: ExerciseCategory) {
        let newExercise = ExerciseModel(name: name, category: category, isCustom: true)
        context.insert(newExercise)
        try? context.save()
    }
}
