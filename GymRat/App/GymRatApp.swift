import SwiftUI
import SwiftData

@main
struct GymRatApp: App {

    @StateObject private var themeManager = ThemeManager()
    @StateObject private var programManager = ProgramManager.shared
    let container: ModelContainer

    init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        let storeURL = appSupport.appendingPathComponent("GymRat.sqlite")

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
            container = created
        } else {
            // Auto-reset broken store, then retry once.
            GymRatApp.resetStoreFiles(at: storeURL)
            guard let retry = try? ModelContainer(for: schema, configurations: [config]) else {
                fatalError("Failed to initialize SwiftData store even after reset.")
            }
            container = retry
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(programManager)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                .tint(themeManager.accentColor)
        }
        .modelContainer(container)
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
