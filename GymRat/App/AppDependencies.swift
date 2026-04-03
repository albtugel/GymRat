import Foundation
import SwiftData

@MainActor
final class AppDependencies {
    static let shared = AppDependencies()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    let exerciseService: ExerciseServiceProtocol
    let programService: ProgramServiceProtocol
    let programAssignmentService: ProgramAssignmentServiceProtocol
    let programExerciseLogService: ProgramExerciseLogServiceProtocol
    let timelineItemService: TimelineItemServiceProtocol
    let dataResetService: DataResetServiceProtocol
    let calendarService: CalendarServiceProtocol
    let themeManager: ThemeManager
    let unitsManager: UnitsManager
    let exerciseStore: ExerciseStore

    private init() {
        let storeURL = Self.makeStoreURL()
        let schema = Schema([
            ProgramModel.self,
            ProgramExercise.self,
            ExerciseModel.self,
            ProgramExerciseLog.self,
            ProgramAssignment.self,
            DayProgramModel.self,
            TimelineItem.self
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

        exerciseStore = ExerciseStore()
        exerciseService = ExerciseService(modelContext: modelContext, exerciseStore: exerciseStore)
        programService = ProgramService(modelContext: modelContext)
        programAssignmentService = ProgramAssignmentService(modelContext: modelContext)
        programExerciseLogService = ProgramExerciseLogService(modelContext: modelContext)
        timelineItemService = TimelineItemService(modelContext: modelContext)
        dataResetService = DataResetService(modelContext: modelContext)
        calendarService = CalendarService()
        themeManager = ThemeManager()
        unitsManager = UnitsManager()
    }

    func makeProgramViewModel() -> ProgramViewModel {
        ProgramViewModel(
            exerciseService: exerciseService,
            programService: programService,
            assignmentService: programAssignmentService,
            dataResetService: dataResetService
        )
    }

    func makeProgramCustomizeViewModel(
        mode: ProgramCustomizeMode,
        program: Program,
        programViewModel: ProgramViewModel
    ) -> ProgramCustomizeViewModel {
        ProgramCustomizeViewModel(
            mode: mode,
            program: program,
            programService: programService,
            exerciseService: exerciseService,
            exerciseLogService: programExerciseLogService,
            exerciseStore: exerciseStore,
            programViewModel: programViewModel
        )
    }

    func makeProgramTableExerciseRowViewModel(
        programExercise: ProgramExercise,
        selectedDate: Date
    ) -> ProgramTableExerciseRowViewModel {
        ProgramTableExerciseRowViewModel(
            programExercise: programExercise,
            selectedDate: selectedDate,
            logService: programExerciseLogService,
            unitsManager: unitsManager,
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
