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
        programExercise: ProgramExercise,
        date: Date,
        repsBySet: [Int],
        weightsBySet: [Double],
        durationsBySet: [Int] = []
    ) {
        self.id = UUID()
        self.programExercise = programExercise
        self.exerciseName = programExercise.exercise.name
        let day = AppCalendar.calendar.startOfDay(for: date)
        self.date = day
        self.dayStamp = ProgramExerciseLog.makeDayStamp(for: day)
        self.repsBySet = repsBySet
        self.weightsBySet = weightsBySet
        self.durationsBySet = durationsBySet
    }

    static func makeDayStamp(for date: Date) -> Int {
        let comps = AppCalendar.calendar.dateComponents([.year, .month, .day], from: date)
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        let day = comps.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}
