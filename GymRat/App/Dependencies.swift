import Foundation
import SwiftData

/// Composition root: opens the store, wires the services, and builds view models for the views
/// (as the app's `ViewModelFactory`). Created once by `GymRatApp`; nothing else should construct it.
@MainActor
final class Dependencies: ViewModelFactory {
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    /// Set when the on-disk store could not be opened on this launch and was replaced with an empty one.
    let storeRecovery: PersistentStore.Recovery?

    let exerciseService: ExerciseServiceType
    let programService: ProgramServiceType
    let programAssignmentService: ScheduleServiceType
    let exerciseLogStore: any ExerciseLogStoreType
    let dataResetService: any DataResetServiceType
    let themeStore: ThemeStore
    let units: Units
    let exerciseStore: any ExerciseStoreType
    let aiSettingsManager: AISettingsManager
    let aiPlanEditingService: AIPlanEditingService

    init() {
        let opened: PersistentStore.Opened
        do {
            opened = try PersistentStore.open(at: PersistentStore.defaultStoreURL())
        } catch {
            fatalError("Failed to create a SwiftData store even after moving the old one aside: \(error)")
        }
        modelContainer = opened.container
        storeRecovery = opened.recovery
        modelContext = modelContainer.mainContext

        exerciseStore = ExerciseRepo()
        exerciseService = ExerciseService(
            modelContext: modelContext,
            exerciseStore: exerciseStore,
            seedStore: ExerciseSeedStore(modelContainer: modelContainer)
        )
        programService = ProgramService(modelContext: modelContext)
        programAssignmentService = ScheduleService(modelContext: modelContext)
        exerciseLogStore = ExerciseLogStore(modelContainer: modelContainer)
        dataResetService = DataResetService(modelContainer: modelContainer)
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
            logStore: exerciseLogStore,
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
            logStore: exerciseLogStore,
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

    func makeDayProgramsViewModel(selectedDate: Date, programViewModel: ProgramViewModel) -> DayProgramsViewModel {
        DayProgramsViewModel(
            selectedDate: selectedDate,
            programViewModel: programViewModel,
            imagePrefetcher: ExerciseImagePrefetcher(exerciseStore: exerciseStore)
        )
    }

    func makeExerciseDetailsViewModel(seed: ExerciseRepo.ExerciseSeed) -> ExerciseDetailsViewModel {
        ExerciseDetailsViewModel(seed: seed, exerciseStore: exerciseStore)
    }
}
