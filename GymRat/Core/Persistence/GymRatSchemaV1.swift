import SwiftData

/// First versioned snapshot of the data model.
///
/// Every future change to a `@Model` gets a new `VersionedSchema` plus a stage in `GymRatMigrationPlan`.
/// When that happens, copy the current model classes into this enum as nested types (the pattern from
/// Apple's SwiftData migration sample) so V1 stays frozen and stores written by earlier releases keep opening.
enum GymRatSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Program.self,
            WorkoutExercise.self,
            Exercise.self,
            ExerciseLog.self,
            ScheduleItem.self,
            DayProgram.self,
            Event.self
        ]
    }
}
