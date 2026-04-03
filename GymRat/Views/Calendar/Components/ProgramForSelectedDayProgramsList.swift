import SwiftUI
import UniformTypeIdentifiers

struct ProgramForSelectedDayProgramsList: View {
    private let selectedDate: Date
    @Binding private var dayPrograms: [ProgramModel]
    @Binding private var draggingProgram: ProgramModel?
    private let onEdit: (ProgramModel) -> Void
    private let onReorder: ([ProgramModel]) -> Void

    init(
        selectedDate: Date,
        dayPrograms: Binding<[ProgramModel]>,
        draggingProgram: Binding<ProgramModel?>,
        onEdit: @escaping (ProgramModel) -> Void,
        onReorder: @escaping ([ProgramModel]) -> Void
    ) {
        self.selectedDate = selectedDate
        self._dayPrograms = dayPrograms
        self._draggingProgram = draggingProgram
        self.onEdit = onEdit
        self.onReorder = onReorder
    }

    // MARK: - Body
    var body: some View {
        ForEach(dayPrograms) { program in
            ProgramTableView(
                program: program,
                selectedDate: selectedDate,
                onEdit: { onEdit($0) }
            )
            .onDrag {
                draggingProgram = program
                return NSItemProvider(item: Data() as NSData, typeIdentifier: UTType.data.identifier)
            }
            .onDrop(
                of: [UTType.data],
                delegate: ProgramDropDelegate(
                    item: program,
                    programs: $dayPrograms,
                    dragging: $draggingProgram,
                    onReorder: onReorder
                )
            )
        }
    }
}
