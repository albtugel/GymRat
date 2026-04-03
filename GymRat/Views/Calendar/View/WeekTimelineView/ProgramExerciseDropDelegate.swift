import SwiftUI
import UniformTypeIdentifiers

struct ProgramExerciseDropDelegate: DropDelegate {
    let item: ProgramExercise
    let program: ProgramModel
    @Binding var dragging: ProgramExercise?
    let onReorder: (IndexSet, Int) -> Void

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging != item else { return }
        guard let fromIndex = program.exercises.firstIndex(of: dragging),
              let toIndex = program.exercises.firstIndex(of: item) else { return }

        let destination = toIndex > fromIndex ? toIndex + 1 : toIndex
        withAnimation(.easeInOut(duration: 0.2)) {
            program.exercises.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: destination
            )
        }
        onReorder(IndexSet(integer: fromIndex), destination)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        return true
    }
}
