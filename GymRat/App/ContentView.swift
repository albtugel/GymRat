import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var programManager = ProgramManager.shared
    @Environment(\.modelContext) private var context
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            WeekTimelineView { showSettings = true }
                .environmentObject(programManager)
                .navigationDestination(isPresented: $showSettings) { SettingsView() }
        }
        .tint(themeManager.accentColor)
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        .task {
            ExerciseSeeder.seedIfNeeded(context: context)
            programManager.loadPrograms(context: context)
        }
    }
}
