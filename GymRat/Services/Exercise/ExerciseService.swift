import Foundation
import SwiftData

@MainActor
final class ExerciseService: ExerciseServiceProtocol {
    private let modelContext: ModelContext
    private let exerciseStore: ExerciseStore

    init(modelContext: ModelContext, exerciseStore: ExerciseStore) {
        self.modelContext = modelContext
        self.exerciseStore = exerciseStore
    }

    func fetchExercises() async throws -> [ExerciseModel] {
        let descriptor = FetchDescriptor<ExerciseModel>()
        return try modelContext.fetch(descriptor)
    }

    func fetchExercise(named name: String) async throws -> ExerciseModel? {
        let descriptor = FetchDescriptor<ExerciseModel>(
            predicate: #Predicate<ExerciseModel> { $0.name == name }
        )
        return try modelContext.fetch(descriptor).first
    }

    func addExercise(_ exercise: ExerciseModel) async throws {
        modelContext.insert(exercise)
        try modelContext.save()
    }

    func seedIfNeeded() async throws {
        let existing = try await fetchExercises()
        let existingNames = Set(existing.map { $0.name.lowercased() })

        var didInsert = false
        for seed in exerciseStore.seeds {
            let key = seed.name.lowercased()
            if !existingNames.contains(key) {
                modelContext.insert(ExerciseModel(name: seed.name, categoryRaw: seed.category.rawValue))
                didInsert = true
            }
        }

        if didInsert {
            try modelContext.save()
        }
    }

    func deleteCustomExercises() async throws {
        let descriptor = FetchDescriptor<ExerciseModel>(
            predicate: #Predicate<ExerciseModel> { $0.isCustom == true }
        )
        let items = try modelContext.fetch(descriptor)
        items.forEach { modelContext.delete($0) }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
