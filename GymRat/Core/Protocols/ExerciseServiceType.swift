import Foundation

@MainActor
protocol ExerciseServiceType {
    func fetchExercises() async throws -> [Exercise]
    func fetchExercise(named name: String) async throws -> Exercise?
    func addExercise(_ exercise: Exercise) async throws
    func seedIfNeeded() async throws
    func deleteCustomExercises() async throws
}
