import SwiftUI
import SwiftData

struct ProgramListView: View {

    @EnvironmentObject var programManager: ProgramManager
    @Environment(\.modelContext) private var context

    @State private var selectedProgram: ProgramModel?
    @State private var mode: ProgramCustomizeMode = .create

    var body: some View {
        List {
            Section("programs_title") {
                ForEach(ProgramType.allCases, id: \.self) { type in
                    Button {
                        // Создаём новую программу для выбранного типа
                        let newProgram = ProgramModel(name: type.title, type: type)
                        selectedProgram = newProgram
                        mode = .create
                    } label: {
                        HStack {
                            Text(type.title)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
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
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .sheet(item: $selectedProgram) { program in
            ProgramCustomizeSheetView(
                mode: mode,
                program: program
            )
            .environmentObject(programManager)
            .environment(\.modelContext, context)
        }
        .navigationTitle("programs_title")
    }
}
