import SwiftUI

struct ProgramListView: View {

    @Environment(ProgramViewModel.self) private var programViewModel

    @State private var selectedProgram: ProgramModel?
    @State private var mode: ProgramCustomizeMode = .create

    var body: some View {
        List {
            Section("programs_title") {
                ForEach(ProgramType.allCases, id: \.self) { type in
                    Button {
                        selectedProgram = programViewModel.makeProgram(for: type)
                        mode = .create
                    } label: {
                        HStack {
                            Text(programViewModel.resolveProgramTitle(for: type))
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
            ProgramCustomizeSheetView(
                viewModel: ProgramCustomizeViewModelFactory.make(
                    mode: mode,
                    program: program,
                    programViewModel: programViewModel
                )
            )
        }
        .navigationTitle("programs_title")
    }
}
