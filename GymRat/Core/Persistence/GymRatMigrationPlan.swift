import SwiftData

/// Ordered history of the data model. SwiftData walks `stages` to bring an older store up to the
/// latest schema instead of failing to open it.
enum GymRatMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [GymRatSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
