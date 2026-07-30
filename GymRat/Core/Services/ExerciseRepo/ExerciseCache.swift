import Foundation

extension ExerciseRepo {
    /// A catalog snapshot together with the paging state needed to resume an interrupted download.
    struct CachedCatalog: Codable {
        var exercises: [RemoteExercise]
        /// Id of the last exercise the bulk pagination returned, replayed as the `after` cursor.
        /// Stored separately from `exercises` because single-id lookups append to that array, so its
        /// last element is not where paging left off.
        var paginationCursor: String?
        /// False while the catalog is still missing pages, which keeps the next launch downloading.
        var isComplete: Bool
    }

    static var cacheFileName: String {
        // v3: v2 stored a bare array with no paging state, so a download cut short by rate limiting
        // froze as if it were the whole catalog and never resumed.
        "exercisedb-exercises-cache-v3.json"
    }

    /// Caches written by earlier builds, deleted once so they stop taking up space.
    static var legacyCacheFileNames: [String] {
        ["exercisedb-exercises-cache.json", "exercisedb-exercises-cache-v2.json"]
    }

    static func cacheURL(fileName: String) -> URL? {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let appDirectory = directory.appendingPathComponent("GymRat", isDirectory: true)
        try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        return appDirectory.appendingPathComponent(fileName)
    }

    static func saveCachedCatalog(_ catalog: CachedCatalog, fileName: String) {
        guard let url = cacheURL(fileName: fileName) else { return }
        do {
            let data = try JSONEncoder().encode(catalog)
            try data.write(to: url, options: [.atomic])
            log("Saved API cache: \(catalog.exercises.count) exercises, complete: \(catalog.isComplete).")
        } catch {
            log("Failed to save cache: \(error.localizedDescription)")
        }
    }

    static func loadCachedCatalog(fileName: String) -> CachedCatalog? {
        guard let url = cacheURL(fileName: fileName) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(CachedCatalog.self, from: data)
        } catch {
            log("Failed to read cache: \(error.localizedDescription)")
            return nil
        }
    }

    static func removeLegacyCaches() {
        for fileName in legacyCacheFileNames {
            guard let url = cacheURL(fileName: fileName),
                  FileManager.default.fileExists(atPath: url.path) else { continue }
            try? FileManager.default.removeItem(at: url)
            log("Removed legacy cache \(fileName).")
        }
    }
}
