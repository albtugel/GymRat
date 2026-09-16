import Foundation
import SwiftData
import Testing
@testable import GymRat

@MainActor
struct ExerciseServiceTests {

    @Test func seedsCatalogExercisesOnce() async throws {
        let container = try Self.makeContainer()
        let store = FakeExerciseStore(seeds: [
            .init(name: "Squat", category: .strength, muscles: [.legs], inputType: .strength),
            .init(name: "Row", category: .strength, muscles: [.back], inputType: .strength)
        ])
        let service = ExerciseService(
            modelContext: container.mainContext,
            exerciseStore: store,
            seedStore: ExerciseSeedStore(modelContainer: container)
        )

        try await service.seedIfNeeded()
        try await service.seedIfNeeded()

        let names = try service.fetchExercises().map(\.name).sorted()
        #expect(names == ["Row", "Squat"])
    }

    /// Seed matching is case-insensitive, so a custom exercise with the same name is not duplicated.
    @Test func seedingKeepsAnExistingExerciseWithTheSameName() async throws {
        let container = try Self.makeContainer()
        let store = FakeExerciseStore(seeds: [
            .init(name: "Squat", category: .strength, muscles: [.legs], inputType: .strength)
        ])
        let service = ExerciseService(
            modelContext: container.mainContext,
            exerciseStore: store,
            seedStore: ExerciseSeedStore(modelContainer: container)
        )
        try service.addExercise(Exercise(name: "squat", categoryRaw: ExerciseCategory.strength.rawValue, isCustom: true))

        try await service.seedIfNeeded()

        let exercises = try service.fetchExercises()
        #expect(exercises.map(\.name) == ["squat"])
        #expect(exercises.first?.isCustom == true)
    }

    private static func makeContainer() throws -> ModelContainer {
        let schema = PersistentStore.schema
        return try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
    }
}
