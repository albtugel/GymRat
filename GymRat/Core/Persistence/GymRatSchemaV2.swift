import SwiftData

/// Current data model. V2 drops the never-used `DayProgram` and `Event` entities of V1; the
/// remaining models are identical, so the migration is lightweight.
///
/// The next model change gets a V3: copy the models it changes into this enum as frozen nested
/// types (as V1 does), add the version to `GymRatMigrationPlan`, and point `PersistentStore.schema`
/// at the new version.
enum GymRatSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Program.self,
            WorkoutExercise.self,
            Exercise.self,
            ExerciseLog.self,
            ScheduleItem.self
        ]
    }
}
