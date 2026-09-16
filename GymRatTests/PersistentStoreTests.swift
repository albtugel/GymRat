import Foundation
import SwiftData
import Testing
@testable import GymRat

struct PersistentStoreTests {

    /// Installs before the versioned schema wrote their store through a plain `Schema`. Opening it
    /// through the migration plan must succeed with the data intact, otherwise the next update wipes every user.
    @Test func opensStoreWrittenWithoutMigrationPlan() throws {
        let storeURL = Self.makeTemporaryStoreURL()
        defer { Self.removeFolder(containing: storeURL) }
        try Self.writeLegacyStore(at: storeURL, programName: "Legacy push day")

        let opened = try PersistentStore.open(at: storeURL)

        #expect(opened.recovery == nil)
        let programs = try ModelContext(opened.container).fetch(FetchDescriptor<Program>())
        #expect(programs.map(\.name) == ["Legacy push day"])
    }

    @Test func unreadableStoreIsMovedToBackupAndReplaced() throws {
        let storeURL = Self.makeTemporaryStoreURL()
        defer { Self.removeFolder(containing: storeURL) }
        let garbage = Data("definitely not a SQLite database".utf8)
        try garbage.write(to: storeURL)
        let walURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        try Data("wal".utf8).write(to: walURL)

        let opened = try PersistentStore.open(at: storeURL)

        let recovery = try #require(opened.recovery)
        let backedUpStore = recovery.backupURL.appendingPathComponent(PersistentStore.fileName)
        #expect(try Data(contentsOf: backedUpStore) == garbage)
        #expect(FileManager.default.fileExists(atPath: recovery.backupURL.appendingPathComponent(walURL.lastPathComponent).path))
        #expect(!FileManager.default.fileExists(atPath: walURL.path))

        let context = ModelContext(opened.container)
        context.insert(Program(name: "Fresh start", typeRaw: ProgramType.strength.rawValue))
        try context.save()
        #expect(try context.fetch(FetchDescriptor<Program>()).map(\.name) == ["Fresh start"])
    }

    @Test func backupFolderIsTimestamped() throws {
        let storeURL = Self.makeTemporaryStoreURL()
        defer { Self.removeFolder(containing: storeURL) }
        try Data("broken".utf8).write(to: storeURL)
        var components = DateComponents()
        components.year = 2026; components.month = 9; components.day = 16
        components.hour = 10; components.minute = 30; components.second = 5
        let date = try #require(Calendar.current.date(from: components))

        let opened = try PersistentStore.open(at: storeURL, now: date)

        let recovery = try #require(opened.recovery)
        #expect(recovery.backupURL.lastPathComponent == "2026-09-16_10-30-05")
        #expect(recovery.backupURL.deletingLastPathComponent().lastPathComponent == PersistentStore.backupsFolderName)
    }

    private static func makeTemporaryStoreURL() -> URL {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("PersistentStoreTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(PersistentStore.fileName)
    }

    private static func removeFolder(containing storeURL: URL) {
        try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
    }

    private static func writeLegacyStore(at storeURL: URL, programName: String) throws {
        let schema = Schema(GymRatSchemaV1.models)
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: storeURL)])
        let context = ModelContext(container)
        context.insert(Program(name: programName, typeRaw: ProgramType.strength.rawValue))
        try context.save()
    }
}
