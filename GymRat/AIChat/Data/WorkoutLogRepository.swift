import Foundation

protocol WorkoutLogRepository {
    func fetchAllLogs() throws -> [ProgramExerciseLog]
}
