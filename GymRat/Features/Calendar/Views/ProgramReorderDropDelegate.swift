import SwiftUI
import UniformTypeIdentifiers

struct ProgramReorderDropDelegate: DropDelegate {
    let item: ProgramSnapshot
    @Binding var programs: [ProgramSnapshot]
    @Binding var dragging: ProgramSnapshot?
    let onReorder: ([ProgramSnapshot]) -> Void

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging.id != item.id else { return }
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
