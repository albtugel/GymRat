import Foundation
import SwiftData

@Model
final class ProgramExercise: Identifiable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .noAction)
    var exercise: ExerciseModel

    var sets: Int
    var reps: Int
    var selectionIndex: Int
    var sharedHistory: Bool = false

    init(
        id: UUID = UUID(),
        exercise: ExerciseModel,
        sets: Int = 3,
        reps: Int = 0,
        selectionIndex: Int = 0,
        sharedHistory: Bool = false
    ) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.reps = reps
        self.selectionIndex = selectionIndex
        self.sharedHistory = sharedHistory
    }
}
