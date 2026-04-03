import SwiftUI
import SwiftData

@main
struct GymRatApp: App {

    @State private var themeManager: ThemeManager
    @State private var programViewModel: ProgramViewModel
    @State private var unitsManager: UnitsManager
    private let dependencies: AppDependencies

    init() {
        dependencies = AppDependencies.shared
        _themeManager = State(initialValue: dependencies.themeManager)
        _unitsManager = State(initialValue: dependencies.unitsManager)
        _programViewModel = State(initialValue: dependencies.makeProgramViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(unitsManager)
                .environment(programViewModel)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                .tint(themeManager.accentColor)
        }
        .modelContainer(dependencies.modelContainer)
    }
}
