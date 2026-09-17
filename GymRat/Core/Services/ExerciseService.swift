import Foundation
import SwiftData

/// SwiftData-backed `ExerciseServiceType`, running on a model actor off the main thread. The first
/// launch inserts the whole catalog, which is too much work for the main actor during startup.
struct ExerciseService: ExerciseServiceType {
    private let storage: BackgroundModelActor<ExerciseStorage>
    private let exerciseStore: any ExerciseStoreType

    init(modelContainer: ModelContainer, exerciseStore: any ExerciseStoreType) {
        storage = BackgroundModelActor { ExerciseStorage(modelContainer: modelContainer) }
        self.exerciseStore = exerciseStore
    }

    func fetchExercises() async throws -> [ExerciseSnapshot] {
        try await storage.get().fetchExercises()
    }

    func fetchExercise(named name: String) async throws -> ExerciseSnapshot? {
        try await storage.get().fetchExercise(named: name)
    }

    func addExercise(_ exercise: ExerciseSnapshot) async throws {
        try await storage.get().addExercise(exercise)
    }

    func seedIfNeeded() async throws {
        let seeds = await exerciseStore.seedSnapshot()
        let inserted = try await storage.get().insertMissing(seeds: seeds)
        if inserted > 0 {
            AppLog.persistence.notice("Seeded \(inserted) catalog exercises")
        }
    }
}

@ModelActor
private actor ExerciseStorage {
    func fetchExercises() throws -> [ExerciseSnapshot] {
        try modelContext.fetch(FetchDescriptor<Exercise>()).map(Self.snapshot)
    }

    func fetchExercise(named name: String) throws -> ExerciseSnapshot? {
        try modelContext
            .fetch(FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == name }))
            .first
            .map(Self.snapshot)
    }

    func addExercise(_ snapshot: ExerciseSnapshot) throws {
        modelContext.insert(Exercise(
            id: snapshot.id,
            name: snapshot.name,
            categoryRaw: snapshot.category.rawValue,
            isCustom: snapshot.isCustom
        ))
        try modelContext.save()
    }

    /// Inserts every seed whose name (case-insensitively) is not stored yet. Returns how many were added.
    func insertMissing(seeds: [ExerciseRepo.ExerciseSeed]) throws -> Int {
        let existingNames = Set(try modelContext.fetch(FetchDescriptor<Exercise>()).map { $0.name.lowercased() })
        var inserted = 0
        for seed in seeds where !existingNames.contains(seed.name.lowercased()) {
            modelContext.insert(Exercise(name: seed.name, categoryRaw: seed.category.rawValue))
            inserted += 1
        }
        if inserted > 0 {
            try modelContext.save()
        }
        AppLog.persistence.debug("Exercise storage ran off the main thread: \(!Thread.isMainThread)")
        return inserted
    }

    static func snapshot(_ exercise: Exercise) -> ExerciseSnapshot {
        ExerciseSnapshot(
            id: exercise.id,
            name: exercise.name,
            category: ExerciseCategory(rawValue: exercise.categoryRaw) ?? .strength,
            isCustom: exercise.isCustom
        )
    }
}
