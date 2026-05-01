import Foundation
import SwiftData

@Model
final class ProgramExerciseLog: Identifiable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .noAction)
    var programExercise: ProgramExercise
    var exerciseName: String?
    var date: Date
    var dayStamp: Int = 0
    var repsBySet: [Int]
    var weightsBySet: [Double]
    var durationsBySet: [Int] = []

    init(
        id: UUID = UUID(),
        programExercise: ProgramExercise,
        exerciseName: String?,
        date: Date,
        dayStamp: Int,
        repsBySet: [Int],
        weightsBySet: [Double],
        durationsBySet: [Int] = []
    ) {
        self.id = id
        self.programExercise = programExercise
        self.exerciseName = exerciseName
        self.date = date
        self.dayStamp = dayStamp
        self.repsBySet = repsBySet
        self.weightsBySet = weightsBySet
        self.durationsBySet = durationsBySet
    }
}
