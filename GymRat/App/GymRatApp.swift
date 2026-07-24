import SwiftUI
import SwiftData
import Kingfisher

@main
struct GymRatApp: App {

    @State private var themeStore: ThemeStore
    @State private var programViewModel: ProgramViewModel
    @State private var units: Units
    @State private var aiSettingsManager: AISettingsManager
    private let dependencies: Dependencies

    init() {
        Self.configureImageCache()
        dependencies = Dependencies.shared
        AITestSupport.resetIfNeeded(dependencies: dependencies)
        _themeStore = State(initialValue: dependencies.themeStore)
        _units = State(initialValue: dependencies.units)
        _aiSettingsManager = State(initialValue: dependencies.aiSettingsManager)
        _programViewModel = State(initialValue: dependencies.makeProgramViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(themeStore)
                .environment(units)
                .environment(aiSettingsManager)
                .environment(programViewModel)
                .preferredColorScheme(themeStore.selectedTheme.colorScheme)
                .tint(themeStore.accentColor)
                .task {
                    _ = await ExerciseRepo.shared.refresh()
                }
        }
        .modelContainer(dependencies.modelContainer)
    }

    /// Exercise GIFs are static content served from a stable, id-based URL, so a downloaded file
    /// stays valid forever. Disable disk-cache expiration to reuse it across launches indefinitely;
    /// it is still wiped by the "reset all data" flow, which clears the cache explicitly.
    private static func configureImageCache() {
        ImageCache.default.diskStorage.config.expiration = .never
    }
}
