import SwiftUI
import UniformTypeIdentifiers

struct ProgramReorderDropDelegate: DropDelegate {
    let item: Program
    @Binding var programs: [Program]
    @Binding var dragging: Program?
    let onReorder: ([Program]) -> Void

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
