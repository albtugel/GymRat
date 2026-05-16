import SwiftUI

struct ProgramsSection: View {
    private let programs: [Program]
    private let hasPrograms: Bool
    private let onSelect: (Program) -> Void
    private let onDelete: (IndexSet) -> Void
    private let onAdd: () -> Void

    init(
        programs: [Program],
        hasPrograms: Bool,
        onSelect: @escaping (Program) -> Void,
        onDelete: @escaping (IndexSet) -> Void,
        onAdd: @escaping () -> Void
    ) {
        self.programs = programs
        self.hasPrograms = hasPrograms
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.onAdd = onAdd
    }


    var body: some View {
        Section("programs_title") {
            if !hasPrograms {
                Text("no_programs_yet")
                    .foregroundColor(.secondary)
            } else {
                ForEach(programs) { program in
                    Button {
                        onSelect(program)
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
                .onDelete(perform: onDelete)
            }

            Button {
                onAdd()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("add_program_button")
                }
                .foregroundColor(.accentColor)
            }
        }
    }
}
