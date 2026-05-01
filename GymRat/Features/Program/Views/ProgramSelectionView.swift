import SwiftUI

struct ProgramSelectionView: View {

    @Environment(ProgramViewModel.self) private var programViewModel
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
                            selectedProgram = programViewModel.makeProgram(
                                name: template.name,
                                typeRaw: template.typeRaw
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

                if programViewModel.hasCustomPrograms {
                    Section("my_programs_section") {
                        ForEach(programViewModel.customPrograms) { program in
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
                    viewModel: ProgramCustomizeViewModelFactory.make(
                        mode: mode,
                        program: program,
                        programViewModel: programViewModel
                    )
                )
            }
        }
    }

    private func deleteProgram(at offsets: IndexSet) {
        Task { await programViewModel.deletePrograms(at: offsets) }
    }
}
