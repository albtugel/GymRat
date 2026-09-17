import Foundation

/// The app's own exercise table: catalog seeds plus the user's custom exercises.
protocol ExerciseServiceType: Sendable {
    func fetchExercises() async throws -> [ExerciseSnapshot]
    func fetchExercise(named name: String) async throws -> ExerciseSnapshot?
    /// Stores a new exercise under the snapshot's own id, so callers can reference it right away.
    func addExercise(_ exercise: ExerciseSnapshot) async throws
    /// Inserts every catalog seed whose name is not stored yet.
    func seedIfNeeded() async throws
}
