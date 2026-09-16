import Foundation
import SwiftData

/// Fills the `Exercise` table from the catalog seeds on a model actor off the main thread. The first
/// launch inserts the whole catalog, which is too much work for the main actor during startup.
struct ExerciseSeedStore {
    private let storage: BackgroundModelActor<ExerciseSeedStorage>

    init(modelContainer: ModelContainer) {
        storage = BackgroundModelActor { ExerciseSeedStorage(modelContainer: modelContainer) }
    }

    /// Inserts every seed whose name (case-insensitively) is not stored yet. Returns how many were added.
    func insertMissing(seeds: [ExerciseRepo.ExerciseSeed]) async throws -> Int {
        try await storage.get().insertMissing(seeds: seeds)
    }
}

@ModelActor
private actor ExerciseSeedStorage {
    func insertMissing(seeds: [ExerciseRepo.ExerciseSeed]) throws -> Int {
        let existingNames = Set(try modelContext.fetch(FetchDescriptor<Exercise>()).map { $0.name.lowercased() })
        var inserted = 0
        for seed in seeds where !existingNames.contains(seed.name.lowercased()) {
            modelContext.insert(Exercise(name: seed.name, categoryRaw: seed.category.rawValue))
            inserted += 1
        }
        if inserted > 0 {
            try modelContext.save()
            AppLog.persistence.notice("Seeded \(inserted) catalog exercises")
        }
        AppLog.persistence.debug("Seed store ran off the main thread: \(!Thread.isMainThread)")
        return inserted
    }
}
