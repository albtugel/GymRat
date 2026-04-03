import SwiftUI

struct ContentView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(ProgramViewModel.self) private var programViewModel
    @State private var showSettings = false
    @State private var weekTimelineViewModel = WeekTimelineViewModel()

    var body: some View {
        NavigationStack {
            WeekTimelineView(viewModel: weekTimelineViewModel) { showSettings = true }
                .navigationDestination(isPresented: $showSettings) { SettingsView() }
        }
        .tint(themeManager.accentColor)
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        .task {
            await programViewModel.seedExercisesIfNeeded()
            await programViewModel.loadPrograms()
            await programViewModel.loadDayPrograms()
        }
    }
}
