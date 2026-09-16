import Foundation
import SwiftData
import Testing
@testable import GymRat

@MainActor
struct ExerciseServiceTests {

    @Test func seedsCatalogExercisesOnce() async throws {
        let store = FakeExerciseStore(seeds: [
            .init(name: "Squat", category: .strength, muscles: [.legs], inputType: .strength),
            .init(name: "Row", category: .strength, muscles: [.back], inputType: .strength)
        ])
        let service = ExerciseService(modelContainer: try Self.makeContainer(), exerciseStore: store)

        try await service.seedIfNeeded()
        try await service.seedIfNeeded()

        let names = try await service.fetchExercises().map(\.name).sorted()
        #expect(names == ["Row", "Squat"])
    }

    /// Seed matching is case-insensitive, so a custom exercise with the same name is not duplicated.
    @Test func seedingKeepsAnExistingExerciseWithTheSameName() async throws {
        let store = FakeExerciseStore(seeds: [
            .init(name: "Squat", category: .strength, muscles: [.legs], inputType: .strength)
        ])
        let service = ExerciseService(modelContainer: try Self.makeContainer(), exerciseStore: store)
        try await service.addExercise(ExerciseSnapshot(name: "squat", category: .strength, isCustom: true))

        try await service.seedIfNeeded()

        let exercises = try await service.fetchExercises()
        #expect(exercises.map(\.name) == ["squat"])
        #expect(exercises.first?.isCustom == true)
    }

    /// Callers reference the exercise by the snapshot's id before the write lands, so it must be kept.
    @Test func storedExerciseKeepsTheSnapshotID() async throws {
        let service = ExerciseService(modelContainer: try Self.makeContainer(), exerciseStore: FakeExerciseStore())
        let exercise = ExerciseSnapshot(name: "Farmer walk", category: .crossfit, isCustom: true)

        try await service.addExercise(exercise)

        #expect(try await service.fetchExercise(named: "Farmer walk") == exercise)
    }

    private static func makeContainer() throws -> ModelContainer {
        let schema = PersistentStore.schema
        return try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
    }
}
