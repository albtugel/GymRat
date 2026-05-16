import SwiftUI
import SwiftData

@main
struct GymRatApp: App {

    @State private var themeStore: ThemeStore
    @State private var programViewModel: ProgramViewModel
    @State private var units: Units
    @State private var aiSettingsManager: AISettingsManager
    private let dependencies: Dependencies

    init() {
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
}
