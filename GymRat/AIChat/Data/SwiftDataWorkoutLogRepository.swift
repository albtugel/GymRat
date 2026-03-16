import Foundation
import SwiftData

struct SwiftDataWorkoutLogRepository: WorkoutLogRepository {
    let context: ModelContext

    func fetchAllLogs() throws -> [ProgramExerciseLog] {
        try context.fetch(FetchDescriptor<ProgramExerciseLog>())
    }
}
