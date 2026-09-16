import Foundation

@MainActor
protocol ExerciseLogServiceType {
    func fetchLogs(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool) throws -> [ExerciseLog]
    func fetchLog(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool, dayStamp: Int) throws -> ExerciseLog?
    func insertLog(_ log: ExerciseLog) throws
    func deleteLog(_ log: ExerciseLog) throws
    func saveChanges() throws
}
