import SwiftUI

struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(ProgramViewModel.self) private var programViewModel
    
    @State private var selectedProgram: ProgramModel?
    @State private var showResetAlert = false
    @State private var showProgramSheet = false
    
    @Environment(UnitsManager.self) private var unitsManager

    var body: some View {
        @Bindable var themeManager = themeManager
        @Bindable var unitsManager = unitsManager
        List {
            Section("appearance_section") {
                ThemeToggleView(selectedTheme: $themeManager.selectedTheme)
                AccentColorPickerView(selectedColor: $themeManager.accentColor)
            }

            Section("programs_title") {
                if !programViewModel.hasCustomPrograms {
                    Text("no_programs_yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(programViewModel.customPrograms) { program in
                        Button {
                            selectedProgram = program
                        } label: {
                            HStack {
                                Text(program.name)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteProgram)
                }
                Button {
                    showProgramSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("add_program_button")
                    }
                    .foregroundColor(.accentColor)
                }
            }

            Section("units_section") {
                Picker("weight_unit_label", selection: $unitsManager.weightUnit) {
                    ForEach(WeightUnit.allCases, id: \.rawValue) { unit in
                        Text(unit.label).tag(unit.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("distance_unit_label", selection: $unitsManager.distanceUnit) {
                    ForEach(DistanceUnit.allCases, id: \.rawValue) { unit in
                        Text(unit.label).tag(unit.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("about_section") {
                HStack {
                    Text("app_version_label")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("developer_label")
                    Spacer()
                    Text("@albtugel")
                        .foregroundColor(.secondary)
                }

                if let supportEmailURL = URL(string: "mailto:al.tugel02@gmail.com") {
                    Link(destination: supportEmailURL) {
                        HStack {
                            Text("support_email_label")
                            Spacer()
                            Text("@email_support")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if let privacyURL = URL(string: "https://albtugel.github.io/GymRat/privacy-policy") {
                    Link(destination: privacyURL) {
                        HStack {
                            Text("privacy_policy_label")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if let githubURL = URL(string: "https://github.com/albtugel/GymRat") {
                    Link(destination: githubURL) {
                        HStack {
                            Text("github_label")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if let exerciseDBURL = URL(string: "https://github.com/yuhonas/free-exercise-db") {
                    Link(destination: exerciseDBURL) {
                        HStack {
                            Text("exercise_images_source_label")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Section("data_section") {
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Text("reset_all_data_button")
                }
            }
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
                resetAllData()
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

    private func deleteProgram(at offsets: IndexSet) {
        Task { await programViewModel.deletePrograms(at: offsets) }
    }

    private func resetAllData() {
        Task { await programViewModel.resetAllData() }
        selectedProgram = nil
    }
}
