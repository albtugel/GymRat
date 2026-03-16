import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var logs: [ExerciseLog]

    init(id: UUID = UUID(), name: String, logs: [ExerciseLog] = []) {
        self.id = id
        self.name = name
        self.logs = logs
    }
}
