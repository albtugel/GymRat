import SwiftUI
import UniformTypeIdentifiers

struct WorkoutExerciseDropDelegate: DropDelegate {
    let item: WorkoutExerciseSnapshot
    @Binding var exercises: [WorkoutExerciseSnapshot]
    @Binding var dragging: WorkoutExerciseSnapshot?
    let onReorder: ([WorkoutExerciseSnapshot]) -> Void

    func dropEntered(info: DropInfo) {
        guard let dragging, dragging.id != item.id else { return }
        guard let fromIndex = exercises.firstIndex(where: { $0.id == dragging.id }),
              let toIndex = exercises.firstIndex(where: { $0.id == item.id }) else { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            exercises.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
        onReorder(exercises)
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        dragging = nil
        onReorder(exercises)
        return true
    }
}
