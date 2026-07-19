import SwiftUI
import UniformTypeIdentifiers

struct ProgramsList: View {
    private let selectedDate: Date
    @Binding private var dayPrograms: [Program]
    @Binding private var draggingProgram: Program?
    private let onEdit: (Program) -> Void
    private let onDelete: (Program) -> Void
    private let onReorder: ([Program]) -> Void

    init(
        selectedDate: Date,
        dayPrograms: Binding<[Program]>,
        draggingProgram: Binding<Program?>,
        onEdit: @escaping (Program) -> Void,
        onDelete: @escaping (Program) -> Void,
        onReorder: @escaping ([Program]) -> Void
    ) {
        self.selectedDate = selectedDate
        self._dayPrograms = dayPrograms
        self._draggingProgram = draggingProgram
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onReorder = onReorder
    }


    var body: some View {
        ForEach(dayPrograms) { program in
            ProgramCard(
                program: program,
                selectedDate: selectedDate,
                onEdit: { onEdit($0) },
                onDelete: { onDelete($0) }
            )
            .onDrag {
                draggingProgram = program
                return NSItemProvider(item: Data() as NSData, typeIdentifier: UTType.data.identifier)
            }
            .onDrop(
                of: [UTType.data],
                delegate: ProgramReorderDropDelegate(
                    item: program,
                    programs: $dayPrograms,
                    dragging: $draggingProgram,
                    onReorder: onReorder
                )
            )
        }
    }
}
