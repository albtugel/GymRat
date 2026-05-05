import Foundation
import SwiftData

@MainActor
final class Dependencies {
    static let shared = Dependencies()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

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

    private init() {
        let storeURL = Self.makeStoreURL()
        let schema = Schema([
            Program.self,
            WorkoutExercise.self,
            Exercise.self,
            ExerciseLog.self,
            ScheduleItem.self,
            DayProgram.self,
            Event.self
        ])
        let config = ModelConfiguration(schema: schema, url: storeURL)

        if let created = try? ModelContainer(for: schema, configurations: [config]) {
            modelContainer = created
        } else {
            Self.resetStoreFiles(at: storeURL)
            guard let retry = try? ModelContainer(for: schema, configurations: [config]) else {
                fatalError("Failed to initialize SwiftData store even after reset.")
            }
            modelContainer = retry
        }

        modelContext = modelContainer.mainContext

        exerciseStore = ExerciseRepo()
        exerciseService = ExerciseService(modelContext: modelContext, exerciseStore: exerciseStore)
        programService = ProgramService(modelContext: modelContext)
        programAssignmentService = ScheduleService(modelContext: modelContext)
        programExerciseLogService = ExerciseLogService(modelContext: modelContext)
        timelineItemService = TimelineService(modelContext: modelContext)
        dataResetService = DataResetService(modelContext: modelContext)
        calendarService = CalendarService()
        themeStore = ThemeStore()
        units = Units()
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

    private static func makeStoreURL() -> URL {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return fileManager.temporaryDirectory.appendingPathComponent("GymRat.sqlite")
        }
        try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        return appSupport.appendingPathComponent("GymRat.sqlite")
    }

    private static func resetStoreFiles(at storeURL: URL) {
        let fm = FileManager.default
        let base = storeURL.deletingPathExtension()
        let wal = base.appendingPathExtension("sqlite-wal")
        let shm = base.appendingPathExtension("sqlite-shm")
        [storeURL, wal, shm].forEach { url in
            if fm.fileExists(atPath: url.path) {
                try? fm.removeItem(at: url)
            }
        }
    }
}
