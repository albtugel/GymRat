import CoreData
import Foundation
import SwiftData
import Testing
@testable import GymRat

/// Stops a data model change from shipping without a migration.
///
/// SwiftData can only open a store whose model matches a version in `GymRatMigrationPlan`. Editing
/// a `@Model` (adding, renaming or retyping a property, adding a model) silently changes the latest
/// schema, and every existing install then fails to open its store on update. These tests pin each
/// schema's checksum so that change fails here first.
@MainActor
struct SchemaGuardTests {

    /// Checksums of every schema that has shipped. Never edit an existing entry.
    private static let recordedChecksums: [String: String] = [
        "0.1.0": "YbEPYMAJXNSWtxd1TvMqIlpFBbMX5+7EIkLlcVlIPR8=",
        "0.2.0": "pCTLpN2sFXMPiTXX4JkZOS2t87hwjO75W6ZOv8s57sE=",
        "1.0.0": "tRfLAeRWhu46rOJG85cN878uAPjwDszsuiF4sl+MHEg=",
        "2.0.0": "K8XE3OlXyTb2jIFj2S4o6DMSY96E7lMRlx/DVbWhsjE="
    ]

    private static let howToChangeModels = """
        The data model changed without a new schema version; existing installs would fail to open \
        their store. Follow "Changing the data model" in README.md: freeze the current latest schema, \
        add a new version with a migration stage, point PersistentStore.schema at it and record its \
        checksum here without editing existing entries.
        """

    @Test func everySchemaMatchesItsRecordedChecksum() throws {
        for schema in GymRatMigrationPlan.schemas {
            let version = "\(schema.versionIdentifier)"
            let recorded = try #require(
                Self.recordedChecksums[version],
                "Schema \(version) has no recorded checksum. \(Self.howToChangeModels)"
            )
            let current = try Self.checksum(of: schema)
            #expect(current == recorded, "Schema \(version) checksum is now \(current). \(Self.howToChangeModels)")
        }
    }

    @Test func storeOpensTheLatestSchemaInThePlan() throws {
        let latest = try #require(GymRatMigrationPlan.schemas.last)
        #expect(PersistentStore.schema.version == latest.versionIdentifier)
    }

    /// Staged migration needs each version to be distinct and connected to the next one.
    @Test func planVersionsAreDistinctAndConnected() throws {
        let schemas = GymRatMigrationPlan.schemas
        var versions: [Schema.Version] = []
        var checksums = Set<String>()
        for schema in schemas {
            versions.append(schema.versionIdentifier)
            checksums.insert(try Self.checksum(of: schema))
        }
        #expect(versions == versions.sorted(), "Schemas must be listed oldest first.")
        #expect(checksums.count == schemas.count, "Two versions have identical models.")
        #expect(GymRatMigrationPlan.stages.count == schemas.count - 1, "Every version needs a stage from the previous one.")
    }

    private static func checksum(of schema: any VersionedSchema.Type) throws -> String {
        let model = try #require(NSManagedObjectModel.makeManagedObjectModel(for: schema.models))
        return model.versionChecksum
    }
}
