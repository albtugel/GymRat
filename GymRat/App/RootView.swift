import SwiftUI

struct RootView: View {
    @Environment(ProgramViewModel.self) private var programViewModel
    @Environment(\.scenePhase) private var scenePhase
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
        .alert(LocalizedStringKey(Alerts.StoreRecovery.title), isPresented: $isStoreRecoveryAlertPresented) {
            Button(LocalizedStringKey("ok_button"), role: .cancel) {}
                .accessibilityIdentifier("storeRecoveryOkButton")
        } message: {
            Text(storeRecoveryMessage)
        }
        .task {
            await programViewModel.seedExercisesIfNeeded()
            await programViewModel.loadPrograms()
        }
        .onChange(of: scenePhase) { _, phase in
            // Entries typed into a row are written on focus loss or a day switch; leaving the app
            // does neither, so flush here before iOS may suspend or terminate the process.
            guard phase != .active else { return }
            Task { await weekCalendarViewModel.saveVisibleLogs() }
        }
    }

    private var storeRecoveryMessage: String {
        let backupName = storeRecovery?.backupURL.lastPathComponent ?? ""
        return String(format: NSLocalizedString(Alerts.StoreRecovery.message, comment: ""), backupName)
    }
}
