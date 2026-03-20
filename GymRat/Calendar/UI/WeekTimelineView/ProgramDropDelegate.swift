import SwiftUI
import UniformTypeIdentifiers

struct ProgramDropDelegate: DropDelegate {
    let item: ProgramModel
    @Binding var programs: [ProgramModel]
    @Binding var dragging: ProgramModel?
    let onReorder: ([ProgramModel]) -> Void

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging != item else { return }
        guard let fromIndex = programs.firstIndex(where: { $0.id == dragging.id }),
              let toIndex = programs.firstIndex(where: { $0.id == item.id }) else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            programs.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
        onReorder(programs)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        onReorder(programs)
        return true
    }
}
