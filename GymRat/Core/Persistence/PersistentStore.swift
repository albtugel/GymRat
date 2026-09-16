import Foundation
import SwiftData

/// Opens the app's on-disk SwiftData store.
///
/// A store that fails to open is never deleted. Its files are moved into a timestamped backup folder
/// next to it and a fresh store is created in its place, so a failed migration or a damaged file costs
/// the user a restart from empty rather than their training history. The result carries a `Recovery`
/// whenever that happened so the UI can tell the user where the old data went.
enum PersistentStore {
    struct Recovery {
        /// Folder holding the store files that could not be opened.
        let backupURL: URL
        let underlyingError: any Error
    }

    struct Opened {
        let container: ModelContainer
        /// Non-nil when the original store was moved aside and replaced with an empty one.
        let recovery: Recovery?
    }

    static let fileName = "GymRat.sqlite"
    static let backupsFolderName = "StoreBackups"

    static func defaultStoreURL(fileManager: FileManager = .default) -> URL {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return fileManager.temporaryDirectory.appendingPathComponent(fileName)
        }
        try? fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        return appSupport.appendingPathComponent(fileName)
    }

    /// Throws only when even a fresh store cannot be created (for example, a full disk).
    static func open(
        at storeURL: URL,
        fileManager: FileManager = .default,
        now: Date = Date()
    ) throws -> Opened {
        do {
            return Opened(container: try makeContainer(at: storeURL), recovery: nil)
        } catch {
            AppLog.persistence.error(
                "Store at \(storeURL.lastPathComponent, privacy: .public) failed to open: \(String(describing: error), privacy: .public)"
            )
            let backupURL = try backUpStoreFiles(at: storeURL, fileManager: fileManager, now: now)
            let container = try makeContainer(at: storeURL)
            AppLog.persistence.notice(
                "Started a fresh store; previous files kept in \(backupURL.lastPathComponent, privacy: .public)"
            )
            return Opened(container: container, recovery: Recovery(backupURL: backupURL, underlyingError: error))
        }
    }

    /// The SQLite database plus its WAL and shared-memory sidecars. All three must move together.
    static func storeFileURLs(for storeURL: URL) -> [URL] {
        let base = storeURL.deletingPathExtension()
        return [
            storeURL,
            base.appendingPathExtension("sqlite-wal"),
            base.appendingPathExtension("sqlite-shm")
        ]
    }

    private static func makeContainer(at storeURL: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: GymRatSchemaV1.self)
        let config = ModelConfiguration(schema: schema, url: storeURL)
        return try ModelContainer(for: schema, migrationPlan: GymRatMigrationPlan.self, configurations: [config])
    }

    /// Moves every existing store file into `<store folder>/StoreBackups/<timestamp>/` and returns that folder.
    private static func backUpStoreFiles(at storeURL: URL, fileManager: FileManager, now: Date) throws -> URL {
        let backupURL = storeURL
            .deletingLastPathComponent()
            .appendingPathComponent(backupsFolderName, isDirectory: true)
            .appendingPathComponent(backupFolderName(for: now), isDirectory: true)
        try fileManager.createDirectory(at: backupURL, withIntermediateDirectories: true)

        for url in storeFileURLs(for: storeURL) where fileManager.fileExists(atPath: url.path) {
            try fileManager.moveItem(at: url, to: backupURL.appendingPathComponent(url.lastPathComponent))
        }
        return backupURL
    }

    private static func backupFolderName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: date)
    }
}
