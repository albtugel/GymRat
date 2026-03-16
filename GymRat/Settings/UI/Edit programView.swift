import SwiftUI
import SwiftData

struct EditProgramView: View {
    @EnvironmentObject private var programManager: ProgramManager
    @Environment(\.modelContext) private var context

    @State private var selectedProgram: ProgramModel?

    var body: some View {
        List {
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
        }
        .navigationTitle("programs_title")
        .sheet(item: $selectedProgram) { program in
            ProgramCustomizeSheetView(
                mode: .edit,
                program: program
            )
            .environmentObject(programManager)
            .environment(\.modelContext, context)
        }
    }

    private func deleteProgram(at offsets: IndexSet) {
        offsets.forEach { idx in
            let program = programManager.customPrograms[idx]
            programManager.deleteProgram(program, context: context)
        }
    }
}
