import Foundation

protocol ProgramExerciseLogServiceProtocol {
    func fetchLogs(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool) async throws -> [ProgramExerciseLog]
    func fetchLog(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool, dayStamp: Int) async throws -> ProgramExerciseLog?
    func insertLog(_ log: ProgramExerciseLog) async throws
    func deleteLog(_ log: ProgramExerciseLog) async throws
    func saveChanges() async throws
}
