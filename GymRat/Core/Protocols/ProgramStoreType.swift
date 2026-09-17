import Foundation

/// Programs and their schedule, off the main actor. The UI works with snapshots; the store owns the
/// `@Model` graph and its consistency rules.
protocol ProgramStoreType: Sendable {
    /// Every program, exercises ordered by position.
    func fetchPrograms() async throws -> [ProgramSnapshot]

    /// Creates the program when its id is unknown, otherwise updates it: details, the exercise list
    /// (added, changed, removed — a removed exercise takes its set history with it) and positions.
    /// A new program also gets schedule entries for this week's selected weekdays.
    /// Returns the stored state.
    func save(_ program: ProgramSnapshot) async throws -> ProgramSnapshot

    /// Removes the program with its exercises, their set history and its schedule entries.
    func deleteProgram(id: UUID) async throws

    /// Rewrites positions so the program's exercises follow `orderedExerciseIDs`.
    func reorderExercises(programID: UUID, orderedExerciseIDs: [UUID]) async throws

    /// Marks every program exercise that uses `exerciseID` as sharing one history.
    func shareHistory(exerciseID: UUID) async throws
}
