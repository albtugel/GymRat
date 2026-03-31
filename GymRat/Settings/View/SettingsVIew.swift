import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var programManager: ProgramManager
    @Environment(\.modelContext) private var context
    
    @State private var selectedProgram: ProgramModel?
    @State private var showResetAlert = false
    @State private var showProgramSheet = false
    
    @ObservedObject var unitsManager = UnitsManager.shared
    @Query private var programs: [ProgramModel]

    var body: some View {
        List {
            Section("appearance_section") {
                ThemeToggleView(selectedTheme: $themeManager.selectedTheme)
                AccentColorPickerView(selectedColor: $themeManager.accentColor)
            }

            Section("programs_title") {
                if programs.isEmpty {
                    Text("no_programs_yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(programs) { program in
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

                Link(destination: URL(string: "mailto:al.tugel02@gmail.com")!) {
                    HStack {
                        Text("support_email_label")
                        Spacer()
                        Text("@email_support")
                            .foregroundColor(.secondary)
                    }
                }

                Link(destination: URL(string: "https://albtugel.github.io/GymRat/privacy-policy")!) {
                    HStack {
                        Text("privacy_policy_label")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.secondary)
                    }
                }

                Link(destination: URL(string: "https://github.com/albtugel/GymRat")!) {
                    HStack {
                        Text("github_label")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.secondary)
                    }
                }

                Link(destination: URL(string: "https://github.com/yuhonas/free-exercise-db")!) {
                    HStack {
                        Text("exercise_images_source_label")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(.secondary)
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
                mode: .edit,
                program: program
            )
            .environmentObject(programManager)
            .environmentObject(themeManager)
            .accentColor(themeManager.accentColor)
            .environment(\.modelContext, context)
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
                .environmentObject(programManager)
                .environmentObject(themeManager)
                .accentColor(themeManager.accentColor)
        }
    }

    private func deleteProgram(at offsets: IndexSet) {
        offsets.forEach { idx in
            let program = programs[idx]
            programManager.deleteProgram(program, context: context)
        }
    }

    private func resetAllData() {
        programManager.programs = []
        programManager.customPrograms = []
        programManager.dayPrograms = [:]
        selectedProgram = nil

        deleteAll(ProgramExerciseLog.self)
        deleteAll(ProgramAssignment.self)
        deleteAll(DayProgramModel.self)
        deleteAll(TimelineItem.self)
        deleteAll(ProgramExercise.self)
        deleteAll(ProgramModel.self)

        if context.hasChanges {
            try? context.save()
        }
    }

    private func deleteCustomExercises() {
        let predicate = #Predicate<ExerciseModel> { $0.isCustom == true }
        let descriptor = FetchDescriptor<ExerciseModel>(predicate: predicate)
        let items = (try? context.fetch(descriptor)) ?? []
        items.forEach { context.delete($0) }
    }
    
    private func deleteAll<T: PersistentModel>(_ type: T.Type) {
        let descriptor = FetchDescriptor<T>()
        let items = (try? context.fetch(descriptor)) ?? []
        items.forEach { context.delete($0) }
    }
}
