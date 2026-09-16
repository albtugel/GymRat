import Foundation

@MainActor
protocol ExerciseServiceType {
    func fetchExercises() throws -> [Exercise]
    func fetchExercise(named name: String) throws -> Exercise?
    func addExercise(_ exercise: Exercise) throws
    func seedIfNeeded() async throws
}
