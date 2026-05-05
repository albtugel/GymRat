import Foundation

@MainActor
protocol ExerciseLogServiceType {
    func fetchLogs(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool) async throws -> [ExerciseLog]
    func fetchLog(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool, dayStamp: Int) async throws -> ExerciseLog?
    func insertLog(_ log: ExerciseLog) async throws
    func deleteLog(_ log: ExerciseLog) async throws
    func saveChanges() async throws
}
