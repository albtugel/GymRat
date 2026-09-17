import SwiftData

/// Ordered history of the data model. SwiftData walks `stages` from whatever version a store was
/// written with to the latest one, so every schema that ever reached users must stay listed.
///
/// - 0.1: first App Store releases, original entity names.
/// - 0.2: entities renamed (6 May 2026).
/// - 1.0: `ScheduleItem.program` optional with an inverse on `Program` (19 July 2026).
/// - 2.0: unused `DayProgram` and `Event` removed.
enum GymRatMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [GymRatSchemaV0_1.self, GymRatSchemaV0_2.self, GymRatSchemaV1.self, GymRatSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            LegacyStoreMigration.stage,
            .lightweight(fromVersion: GymRatSchemaV0_2.self, toVersion: GymRatSchemaV1.self),
            .lightweight(fromVersion: GymRatSchemaV1.self, toVersion: GymRatSchemaV2.self)
        ]
    }
}
