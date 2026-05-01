import SwiftUI

struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(ProgramViewModel.self) private var programViewModel
    @Environment(UnitsManager.self) private var unitsManager
    @State private var viewModel: SettingsViewModel
    @State private var selectedProgram: ProgramModel?
    @State private var showResetAlert = false
    @State private var showProgramSheet = false
    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var themeManager = themeManager
        @Bindable var unitsManager = unitsManager
        List {
            SettingsAppearanceSectionView(
                selectedTheme: $themeManager.selectedTheme,
                accentColor: $themeManager.accentColor
            )

            SettingsProgramsSectionView(
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

            SettingsUnitsSectionView(
                weightUnit: $unitsManager.weightUnit,
                distanceUnit: $unitsManager.distanceUnit
            )

            SettingsAboutSectionView(
                appVersion: viewModel.appVersion,
                developerHandle: viewModel.developerHandle,
                supportEmailURL: viewModel.supportEmailURL,
                privacyURL: viewModel.privacyURL,
                githubURL: viewModel.githubURL,
                exerciseDBURL: viewModel.exerciseDBURL
            )

            SettingsDataSectionView(onReset: { showResetAlert = true })
        }
        .navigationTitle("settings_title")
        .sheet(item: $selectedProgram) { program in
            ProgramCustomizeSheetView(
                viewModel: ProgramCustomizeViewModelFactory.make(
                    mode: .edit,
                    program: program,
                    programViewModel: programViewModel
                )
            )
            .environment(themeManager)
            .accentColor(themeManager.accentColor)
        }
        .alert(LocalizedStringKey(AppAlerts.ResetData.title), isPresented: $showResetAlert) {
            Button("reset_button", role: .destructive) {
                Task { await viewModel.resetAllData(programViewModel: programViewModel) }
                selectedProgram = nil
            }
            Button("cancel_button", role: .cancel) { }
        } message: {
            Text(LocalizedStringKey(AppAlerts.ResetData.message))
        }
        .sheet(isPresented: $showProgramSheet) {
            ProgramSelectionView(selectedDate: .constant(Date()))
                .environment(programViewModel)
                .environment(themeManager)
                .accentColor(themeManager.accentColor)
        }
    }
}
