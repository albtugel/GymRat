import Foundation

@MainActor
protocol ExerciseServiceProtocol {
    func fetchExercises() async throws -> [ExerciseModel]
    func fetchExercise(named name: String) async throws -> ExerciseModel?
    func addExercise(_ exercise: ExerciseModel) async throws
    func seedIfNeeded() async throws
    func deleteCustomExercises() async throws
}
