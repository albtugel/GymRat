import SwiftUI

struct EditProgramView: View {
    @Environment(ProgramViewModel.self) private var programViewModel

    @State private var selectedProgram: ProgramModel?

    var body: some View {
        List {
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
        }
        .navigationTitle("programs_title")
        .sheet(item: $selectedProgram) { program in
            ProgramCustomizeSheetView(
                viewModel: ProgramCustomizeViewModelFactory.make(
                    mode: .edit,
                    program: program,
                    programViewModel: programViewModel
                )
            )
        }
    }

    private func deleteProgram(at offsets: IndexSet) {
        offsets.forEach { idx in
            let program = programViewModel.customPrograms[idx]
            Task { await programViewModel.deleteProgram(program) }
        }
    }
}
