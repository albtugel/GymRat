import SwiftUI
import SwiftData

@main
struct GymRatApp: App {

    @State private var themeStore: ThemeStore
    @State private var programViewModel: ProgramViewModel
    @State private var units: Units
    private let dependencies: Dependencies

    init() {
        dependencies = Dependencies.shared
        _themeStore = State(initialValue: dependencies.themeStore)
        _units = State(initialValue: dependencies.units)
        _programViewModel = State(initialValue: dependencies.makeProgramViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(themeStore)
                .environment(units)
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
