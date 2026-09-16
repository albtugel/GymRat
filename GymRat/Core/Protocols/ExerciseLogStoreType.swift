import Foundation

/// Set entries for one day, in storage units (kg, metres, seconds). Arrays are indexed by set.
struct ExerciseLogValues: Sendable, Equatable {
    var repsBySet: [Int]
    var weightsBySet: [Double]
    var durationsBySet: [Int]

    var hasValues: Bool {
        repsBySet.contains { $0 > 0 } || weightsBySet.contains { $0 > 0 } || durationsBySet.contains { $0 > 0 }
    }

    var setCount: Int {
        max(repsBySet.count, weightsBySet.count, durationsBySet.count)
    }
}

/// One stored day of a program exercise's history.
struct ExerciseLogSnapshot: Sendable, Equatable {
    let id: UUID
    let dayStamp: Int
    let values: ExerciseLogValues
}

/// Whose history a row reads and writes: one program exercise, or every program exercise that uses
/// the same catalog exercise when `sharedHistory` is on.
struct ExerciseLogScope: Sendable, Equatable {
    let programExerciseID: UUID
    let exerciseID: UUID
    let sharedHistory: Bool
}

/// Reads and writes set entries away from the main actor. Callers only ever see snapshots, so an
/// implementation is free to run on its own `ModelContext`.
protocol ExerciseLogStoreType: Sendable {
    /// Every log in the scope, at most one per day, ordered by day. Stored dates are normalized to
    /// whole days and duplicate logs for a day are collapsed to the most complete one on the way.
    func fetchLogs(in scope: ExerciseLogScope) async throws -> [ExerciseLogSnapshot]

    /// Writes the entries for `day`, creating or updating that day's log. A log without values is
    /// removed unless `keepEmpty` asks to keep it (to remember an edited set count). When `sets` is
    /// given it is written to the program exercise as its default set count.
    /// Returns the stored log, or nil when it was removed.
    func saveLog(
        in scope: ExerciseLogScope,
        day: Date,
        sets: Int?,
        values: ExerciseLogValues,
        keepEmpty: Bool
    ) async throws -> ExerciseLogSnapshot?

    func deleteLogs(in scope: ExerciseLogScope) async throws
}
