import SwiftData

/// Ordered history of the data model. SwiftData walks `stages` to bring an older store up to the
/// latest schema instead of failing to open it.
enum GymRatMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [GymRatSchemaV1.self, GymRatSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: GymRatSchemaV1.self, toVersion: GymRatSchemaV2.self)
        ]
    }
}
