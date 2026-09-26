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

    let exerciseService: any ExerciseServiceType
    let programStore: any ProgramStoreType
    let exerciseLogStore: any ExerciseLogStoreType
    let dataResetService: any DataResetServiceType
    let themeStore: ThemeStore
    let units: Units
    let exerciseStore: any ExerciseStoreType
    let aiSettingsManager: AISettingsManager
    let aiPlanEditingService: AIPlanEditingService
    let poseDetector: any PoseDetectorType

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
        exerciseService = ExerciseService(modelContainer: modelContainer, exerciseStore: exerciseStore)
        programStore = ProgramStore(modelContainer: modelContainer)
        exerciseLogStore = ExerciseLogStore(modelContainer: modelContainer)
        dataResetService = DataResetService(modelContainer: modelContainer)
        themeStore = ThemeStore()
        units = Units()
        aiSettingsManager = AISettingsManager()
        aiPlanEditingService = AIPlanEditingService()
        poseDetector = PoseDetector()
    }

    func makeProgramViewModel() -> ProgramViewModel {
        ProgramViewModel(
            exerciseService: exerciseService,
            programStore: programStore,
            dataResetService: dataResetService
        )
    }

    func makeProgramEditorViewModel(
        mode: ProgramEditorMode,
        program: ProgramSnapshot,
        programViewModel: ProgramViewModel
    ) -> ProgramEditorViewModel {
        let picker = ExercisePickerViewModel(
            programID: program.id,
            programType: program.type,
            isEditing: mode == .edit,
            selectedExercises: program.exercises,
            exerciseService: exerciseService,
            programStore: programStore,
            logStore: exerciseLogStore,
            exerciseStore: exerciseStore
        )
        return ProgramEditorViewModel(
            mode: mode,
            program: program,
            picker: picker,
            programViewModel: programViewModel
        )
    }

    func makeExerciseRowViewModel(
        programExercise: WorkoutExerciseSnapshot,
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

    func makePoseTestViewModel() -> PoseTestViewModel {
        PoseTestViewModel(detector: poseDetector)
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
