import SwiftUI
import UniformTypeIdentifiers

struct ProgramsList: View {
    private let selectedDate: Date
    @Binding private var dayPrograms: [ProgramSnapshot]
    @Binding private var draggingProgram: ProgramSnapshot?
    private let onEdit: (ProgramSnapshot) -> Void
    private let onDelete: (ProgramSnapshot) -> Void
    private let onReorder: ([ProgramSnapshot]) -> Void

    init(
        selectedDate: Date,
        dayPrograms: Binding<[ProgramSnapshot]>,
        draggingProgram: Binding<ProgramSnapshot?>,
        onEdit: @escaping (ProgramSnapshot) -> Void,
        onDelete: @escaping (ProgramSnapshot) -> Void,
        onReorder: @escaping ([ProgramSnapshot]) -> Void
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
