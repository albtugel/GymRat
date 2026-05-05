import SwiftUI

struct RootView: View {
    @Environment(ThemeStore.self) private var themeStore
    @Environment(ProgramViewModel.self) private var programViewModel
    @State private var showSettings = false
    @State private var weekCalendarViewModel = WeekViewModel()
    @State private var settingsViewModel = Dependencies.shared.makeSettingsViewModel()

    var body: some View {
        NavigationStack {
            WeekView(viewModel: weekCalendarViewModel) { showSettings = true }
                .navigationDestination(isPresented: $showSettings) {
                    SettingsView(viewModel: settingsViewModel)
                }
        }
        .tint(themeStore.accentColor)
        .preferredColorScheme(themeStore.selectedTheme.colorScheme)
        .task {
            await programViewModel.seedExercisesIfNeeded()
            await programViewModel.loadPrograms()
            await programViewModel.loadSchedules()
        }
    }
}
