import SwiftUI
import SwiftData

struct ProgramSelectionView: View {

    @EnvironmentObject var programManager: ProgramManager
    @Environment(\.modelContext) private var context // <-- вот контекст
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedDate: Date

    @State private var selectedProgram: ProgramModel?
    @State private var mode: ProgramCustomizeMode = .create

    var body: some View {
        NavigationStack {
            List {
                Section("templates_section") {
                    ForEach(ProgramTemplate.templates) { template in
                        Button {
                            selectedProgram = ProgramModel(
                                name: template.name,
                                type: template.type
                            )
                            mode = .create
                        } label: {
                            HStack {
                                Text(template.name)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !programManager.customPrograms.isEmpty {
                    Section("my_programs_section") {
                        ForEach(programManager.customPrograms) { program in
                            Button {
                                selectedProgram = program
                                mode = .edit
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
                        .onDelete(perform: deleteProgram) // <-- будет передан context
                    }
                }
            }
            .navigationTitle("select_program_title")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel_button") { dismiss() }
                }
            }
            .sheet(item: $selectedProgram) { program in
                ProgramCustomizeSheetView(
                    mode: mode,
                    program: program
                )
                .environmentObject(programManager)
                .environment(\.modelContext, context) // <-- передаем контекст сюда
            }
        }
    }

    private func deleteProgram(at offsets: IndexSet) {
        offsets.forEach { idx in
            let program = programManager.customPrograms[idx]
            programManager.deleteProgram(program, context: context) // <-- контекст передан
        }
    }
}
