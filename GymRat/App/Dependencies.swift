import Foundation
import SwiftData

@MainActor
final class Dependencies {
    static let shared = Dependencies()

    let modelContainer: ModelContainer
    let modelContext: ModelContext
    /// Set when the on-disk store could not be opened on this launch and was replaced with an empty one.
    let storeRecovery: PersistentStore.Recovery?

    let exerciseService: ExerciseServiceType
    let programService: ProgramServiceType
    let programAssignmentService: ScheduleServiceType
    let programExerciseLogService: ExerciseLogServiceType
    let timelineItemService: TimelineServiceType
    let dataResetService: DataResetServiceType
    let calendarService: CalendarServiceType
    let themeStore: ThemeStore
    let units: Units
    let exerciseStore: ExerciseRepo
    let aiSettingsManager: AISettingsManager
    let aiPlanEditingService: AIPlanEditingService

    private init() {
        let opened: PersistentStore.Opened
        do {
            opened = try PersistentStore.open(at: PersistentStore.defaultStoreURL())
        } catch {
            fatalError("Failed to create a SwiftData store even after moving the old one aside: \(error)")
        }
        modelContainer = opened.container
        storeRecovery = opened.recovery
        modelContext = modelContainer.mainContext

        exerciseStore = ExerciseRepo.shared
        exerciseService = ExerciseService(modelContext: modelContext, exerciseStore: exerciseStore)
        programService = ProgramService(modelContext: modelContext)
        programAssignmentService = ScheduleService(modelContext: modelContext)
        programExerciseLogService = ExerciseLogService(modelContext: modelContext)
        timelineItemService = TimelineService(modelContext: modelContext)
        dataResetService = DataResetService(modelContext: modelContext)
        calendarService = CalendarService()
        themeStore = ThemeStore()
        units = Units()
        aiSettingsManager = AISettingsManager()
        aiPlanEditingService = AIPlanEditingService()
    }

    func makeProgramViewModel() -> ProgramViewModel {
        ProgramViewModel(
            exerciseService: exerciseService,
            programService: programService,
            assignmentService: programAssignmentService,
            dataResetService: dataResetService
        )
    }

    func makeProgramEditorViewModel(
        mode: ProgramEditorMode,
        program: Program,
        programViewModel: ProgramViewModel
    ) -> ProgramEditorViewModel {
        ProgramEditorViewModel(
            mode: mode,
            program: program,
            programService: programService,
            exerciseService: exerciseService,
            exerciseLogService: programExerciseLogService,
            exerciseStore: exerciseStore,
            programViewModel: programViewModel
        )
    }

    func makeExerciseRowViewModel(
        programExercise: WorkoutExercise,
        selectedDate: Date
    ) -> ExerciseRowViewModel {
        ExerciseRowViewModel(
            programExercise: programExercise,
            selectedDate: selectedDate,
            logService: programExerciseLogService,
            units: units,
            exerciseStore: exerciseStore
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(dataResetService: dataResetService)
    }

    func makeAIPlanEditViewModel(programEditorViewModel: ProgramEditorViewModel) -> AIPlanEditViewModel {
        AIPlanEditViewModel(
            programEditorViewModel: programEditorViewModel,
            settingsManager: aiSettingsManager,
            editingService: aiPlanEditingService,
            audioRecorder: AudioRecorder()
        )
    }
}
