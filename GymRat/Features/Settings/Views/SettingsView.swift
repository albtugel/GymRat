import SwiftUI

struct SettingsView: View {
    @Environment(ThemeStore.self) private var themeStore
    @Environment(ProgramViewModel.self) private var programViewModel
    @Environment(Units.self) private var units
    @State private var viewModel: SettingsViewModel
    @State private var selectedProgram: Program?
    @State private var showResetAlert = false
    @State private var showProgramSheet = false
    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var themeStore = themeStore
        @Bindable var units = units
        List {
            AppearanceSection(
                selectedTheme: $themeStore.selectedTheme,
                accentColor: $themeStore.accentColor
            )

            ProgramsSection(
                programs: programViewModel.customPrograms,
                hasPrograms: programViewModel.hasCustomPrograms,
                onSelect: { selectedProgram = $0 },
                onDelete: { offsets in
                    Task {
                        await viewModel.deletePrograms(at: offsets, programViewModel: programViewModel)
                    }
                },
                onAdd: { showProgramSheet = true }
            )

            UnitsSection(
                weightUnit: $units.weightUnit,
                distanceUnit: $units.distanceUnit
            )

            AboutSection(
                appVersion: viewModel.appVersion,
                developerHandle: viewModel.developerHandle,
                supportEmailURL: viewModel.supportEmailURL,
                privacyURL: viewModel.privacyURL,
                githubURL: viewModel.githubURL,
                exerciseDBURL: viewModel.exerciseDBURL
            )

            DataSection(onReset: { showResetAlert = true })
        }
        .navigationTitle("settings_title")
        .sheet(item: $selectedProgram) { program in
            ProgramEditorView(
                viewModel: ProgramEditorFactory.make(
                    mode: .edit,
                    program: program,
                    programViewModel: programViewModel
                )
            )
            .environment(themeStore)
            .accentColor(themeStore.accentColor)
        }
        .alert(LocalizedStringKey(Alerts.ResetData.title), isPresented: $showResetAlert) {
            Button("reset_button", role: .destructive) {
                Task { await viewModel.resetAllData(programViewModel: programViewModel) }
                selectedProgram = nil
            }
            Button("cancel_button", role: .cancel) { }
        } message: {
            Text(LocalizedStringKey(Alerts.ResetData.message))
        }
        .sheet(isPresented: $showProgramSheet) {
            ProgramPickerView(selectedDate: .constant(Date()))
                .environment(programViewModel)
                .environment(themeStore)
                .accentColor(themeStore.accentColor)
        }
    }
}
