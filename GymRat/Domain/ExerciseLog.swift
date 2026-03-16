import Foundation
import SwiftData

@Model
final class ExerciseLog {
    var weight: Double
    var reps: Int
    var date: Date

    init(weight: Double, reps: Int, date: Date = Date()) {
        self.weight = weight
        self.reps = reps
        self.date = date
    }
}
