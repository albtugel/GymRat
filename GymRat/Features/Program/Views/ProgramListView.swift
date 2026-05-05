import SwiftUI

struct ProgramListView: View {

    @Environment(ProgramViewModel.self) private var programViewModel

    @State private var selectedProgram: Program?
    @State private var mode: ProgramEditorMode = .create

    var body: some View {
        List {
            Section("programs_title") {
                ForEach(ProgramType.allCases, id: \.self) { type in
                    Button {
                        selectedProgram = programViewModel.makeProgram(for: type)
                        mode = .create
                    } label: {
                        HStack {
                            Text(programViewModel.title(for: type))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
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
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .sheet(item: $selectedProgram) { program in
            ProgramEditorView(
                viewModel: ProgramEditorFactory.make(
                    mode: mode,
                    program: program,
                    programViewModel: programViewModel
                )
            )
        }
        .navigationTitle("programs_title")
    }
}
