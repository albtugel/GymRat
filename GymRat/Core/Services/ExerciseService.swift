import Foundation
import SwiftData

@MainActor
final class ExerciseService: ExerciseServiceType {
    private let modelContext: ModelContext
    private let exerciseStore: any ExerciseStoreType
    private let seedStore: ExerciseSeedStore

    init(modelContext: ModelContext, exerciseStore: any ExerciseStoreType, seedStore: ExerciseSeedStore) {
        self.modelContext = modelContext
        self.exerciseStore = exerciseStore
        self.seedStore = seedStore
    }

    func fetchExercises() throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>()
        return try modelContext.fetch(descriptor)
    }

    func fetchExercise(named name: String) throws -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { $0.name == name }
        )
        return try modelContext.fetch(descriptor).first
    }

    func addExercise(_ exercise: Exercise) throws {
        modelContext.insert(exercise)
        try modelContext.save()
    }

    func seedIfNeeded() async throws {
        let seeds = await exerciseStore.seedSnapshot()
        _ = try await seedStore.insertMissing(seeds: seeds)
    }

    func deleteCustomExercises() throws {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { $0.isCustom == true }
        )
        let items = try modelContext.fetch(descriptor)
        items.forEach { modelContext.delete($0) }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
