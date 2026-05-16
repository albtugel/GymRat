import Foundation
import SwiftData

@MainActor
final class ExerciseService: ExerciseServiceType {
    private let modelContext: ModelContext
    private let exerciseStore: ExerciseRepo

    init(modelContext: ModelContext, exerciseStore: ExerciseRepo) {
        self.modelContext = modelContext
        self.exerciseStore = exerciseStore
    }

    func fetchExercises() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>()
        return try modelContext.fetch(descriptor)
    }

    func fetchExercise(named name: String) async throws -> Exercise? {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { $0.name == name }
        )
        return try modelContext.fetch(descriptor).first
    }

    func addExercise(_ exercise: Exercise) async throws {
        modelContext.insert(exercise)
        try modelContext.save()
    }

    func seedIfNeeded() async throws {
        let existing = try await fetchExercises()
        let existingNames = Set(existing.map { $0.name.lowercased() })

        var didInsert = false
        let seeds = await exerciseStore.seedSnapshot()
        for seed in seeds {
            let key = seed.name.lowercased()
            if !existingNames.contains(key) {
                modelContext.insert(Exercise(name: seed.name, categoryRaw: seed.category.rawValue))
                didInsert = true
            }
        }

        if didInsert {
            try modelContext.save()
        }
    }

    func deleteCustomExercises() async throws {
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
