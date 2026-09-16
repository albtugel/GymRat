import SwiftUI

struct RootView: View {
    @Environment(ThemeStore.self) private var themeStore
    @Environment(ProgramViewModel.self) private var programViewModel
    @State private var showSettings = false
    @State private var weekCalendarViewModel = WeekViewModel()
    @State private var settingsViewModel: SettingsViewModel
    @State private var isStoreRecoveryAlertPresented: Bool

    private let storeRecovery: PersistentStore.Recovery?

    init(storeRecovery: PersistentStore.Recovery?, viewModelFactory: any ViewModelFactory) {
        self.storeRecovery = storeRecovery
        _settingsViewModel = State(initialValue: viewModelFactory.makeSettingsViewModel())
        _isStoreRecoveryAlertPresented = State(initialValue: storeRecovery != nil)
    }

    var body: some View {
        NavigationStack {
            WeekView(viewModel: weekCalendarViewModel) { showSettings = true }
                .navigationDestination(isPresented: $showSettings) {
                    SettingsView(viewModel: settingsViewModel)
                }
        }
        .tint(themeStore.accentColor)
        .preferredColorScheme(themeStore.selectedTheme.colorScheme)
        .alert(LocalizedStringKey(Alerts.StoreRecovery.title), isPresented: $isStoreRecoveryAlertPresented) {
            Button(LocalizedStringKey("ok_button"), role: .cancel) {}
                .accessibilityIdentifier("storeRecoveryOkButton")
        } message: {
            Text(storeRecoveryMessage)
        }
        .task {
            await programViewModel.seedExercisesIfNeeded()
            programViewModel.loadPrograms()
            programViewModel.loadSchedules()
        }
    }

    private var storeRecoveryMessage: String {
        let backupName = storeRecovery?.backupURL.lastPathComponent ?? ""
        return String(format: NSLocalizedString(Alerts.StoreRecovery.message, comment: ""), backupName)
    }
}
