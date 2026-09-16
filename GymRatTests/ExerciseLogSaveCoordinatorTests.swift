import Foundation
import Testing
@testable import GymRat

@MainActor
struct ExerciseLogSaveCoordinatorTests {

    @Test func saveAllWritesEveryRegisteredRow() async throws {
        let fixture = try ExerciseRowFixture()
        let coordinator = ExerciseLogSaveCoordinator()
        let row = fixture.makeViewModel()
        await row.load()
        coordinator.register(row)
        await fixture.enterReps("8", into: row)
        #expect(fixture.logStore.logs.isEmpty)

        await coordinator.saveAll()

        #expect(fixture.logStore.logs.map(\.values.repsBySet) == [[8, 0, 0]])
        #expect(!row.hasUnsavedChanges)
    }

    @Test func unregisteredRowIsLeftAlone() async throws {
        let fixture = try ExerciseRowFixture()
        let coordinator = ExerciseLogSaveCoordinator()
        let row = fixture.makeViewModel()
        await row.load()
        coordinator.register(row)
        coordinator.unregister(row)
        await fixture.enterReps("8", into: row)

        await coordinator.saveAll()

        #expect(fixture.logStore.logs.isEmpty)
        #expect(row.hasUnsavedChanges)
    }

    @Test func releasedRowsAreDropped() async throws {
        let fixture = try ExerciseRowFixture()
        let coordinator = ExerciseLogSaveCoordinator()
        do {
            let row = fixture.makeViewModel()
            coordinator.register(row)
            #expect(coordinator.registeredRowCount == 1)
        }

        await coordinator.saveAll()

        #expect(coordinator.registeredRowCount == 0)
    }
}
