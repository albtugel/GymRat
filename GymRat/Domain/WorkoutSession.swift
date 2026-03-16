import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var date: Date
    var exercises: [Exercise]

    init(date: Date, exercises: [Exercise] = []) {
        self.date = date
        self.exercises = exercises
    }
}
