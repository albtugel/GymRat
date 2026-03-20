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

    var body: some View {
        List {
            Section("appearance_section") {
                ThemeToggleView(selectedTheme: $themeManager.selectedTheme)
                AccentColorPickerView(selectedColor: $themeManager.accentColor)
            }

            Section("programs_title") {
                if programManager.customPrograms.isEmpty {
                    Text("no_programs_yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(programManager.customPrograms) { program in
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
        .alert("reset_all_data_title", isPresented: $showResetAlert) {
            Button("reset_button", role: .destructive) {
                resetAllData()
            }
            Button("cancel_button", role: .cancel) { }
        } message: {
            Text("reset_all_data_message")
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
            let program = programManager.customPrograms[idx]
            programManager.deleteProgram(program, context: context)
        }
    }

    private func resetAllData() {
        deleteAll(ProgramExerciseLog.self)
        deleteAll(ProgramAssignment.self)
        deleteAll(DayProgramModel.self)
        deleteAll(ProgramModel.self)

        if context.hasChanges {
            try? context.save()
        }

        programManager.programs = []
        programManager.customPrograms = []
        programManager.dayPrograms = [:]
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
