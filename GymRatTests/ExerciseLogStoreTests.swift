import Foundation
import SwiftData
import Testing
@testable import GymRat

/// The real store against an in-memory container: it runs on its own context, so every assertion
/// reads back through a fresh context rather than trusting objects held on the main actor.
@MainActor
struct ExerciseLogStoreTests {

    @Test func savedLogComesBackFromFetch() async throws {
        let fixture = try ExerciseRowFixture()
        let store = ExerciseLogStore(modelContainer: fixture.container)
        let values = ExerciseLogValues(repsBySet: [10, 8, 0], weightsBySet: [60, 60, 0], durationsBySet: [0, 0, 0])

        let saved = try await store.saveLog(in: fixture.scope, day: fixture.today, sets: nil, values: values, keepEmpty: false)
        let logs = try await store.fetchLogs(in: fixture.scope)

        #expect(saved?.values == values)
        #expect(logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
        #expect(logs.first?.values == values)
    }

    @Test func savingWithoutValuesRemovesTheDaysLog() async throws {
        let fixture = try ExerciseRowFixture()
        let store = ExerciseLogStore(modelContainer: fixture.container)
        _ = try await store.saveLog(
            in: fixture.scope, day: fixture.today, sets: nil,
            values: ExerciseLogValues(repsBySet: [10], weightsBySet: [0], durationsBySet: [0]), keepEmpty: false
        )

        let result = try await store.saveLog(
            in: fixture.scope, day: fixture.today, sets: nil,
            values: ExerciseLogValues(repsBySet: [0], weightsBySet: [0], durationsBySet: [0]), keepEmpty: false
        )

        #expect(result == nil)
        #expect(try await store.fetchLogs(in: fixture.scope).isEmpty)
        #expect(try ModelContext(fixture.container).fetch(FetchDescriptor<ExerciseLog>()).isEmpty)
    }

    @Test func keepEmptyStoresTheSetCount() async throws {
        let fixture = try ExerciseRowFixture()
        let store = ExerciseLogStore(modelContainer: fixture.container)

        let saved = try await store.saveLog(
            in: fixture.scope, day: fixture.today, sets: 4,
            values: ExerciseLogValues(repsBySet: [0, 0, 0, 0], weightsBySet: [0, 0, 0, 0], durationsBySet: [0, 0, 0, 0]),
            keepEmpty: true
        )

        #expect(saved?.values.setCount == 4)
        let programExerciseID = fixture.programExercise.id
        let stored = try ModelContext(fixture.container)
            .fetch(FetchDescriptor<WorkoutExercise>(predicate: #Predicate { $0.id == programExerciseID }))
            .first
        #expect(stored?.sets == 4)
    }

    @Test func sharedHistoryReadsEveryProgramExerciseOfTheExercise() async throws {
        let fixture = try ExerciseRowFixture()
        let other = WorkoutExercise(exercise: fixture.exercise, sets: 3, sharedHistory: true)
        fixture.container.mainContext.insert(other)
        try fixture.container.mainContext.save()
        let store = ExerciseLogStore(modelContainer: fixture.container)
        let otherScope = ExerciseLogScope(programExerciseID: other.id, exerciseID: fixture.exercise.id, sharedHistory: false)
        _ = try await store.saveLog(
            in: fixture.scope, day: fixture.today, sets: nil,
            values: ExerciseLogValues(repsBySet: [5], weightsBySet: [0], durationsBySet: [0]), keepEmpty: false
        )
        _ = try await store.saveLog(
            in: otherScope, day: fixture.tomorrow, sets: nil,
            values: ExerciseLogValues(repsBySet: [7], weightsBySet: [0], durationsBySet: [0]), keepEmpty: false
        )

        let shared = ExerciseLogScope(programExerciseID: other.id, exerciseID: fixture.exercise.id, sharedHistory: true)
        let logs = try await store.fetchLogs(in: shared)

        #expect(logs.map(\.values.repsBySet) == [[5], [7]])
        #expect(try await store.fetchLogs(in: otherScope).map(\.values.repsBySet) == [[7]])
    }

    @Test func fetchCollapsesDuplicateLogsForADay() async throws {
        let fixture = try ExerciseRowFixture()
        let context = fixture.container.mainContext
        let dayStamp = ExerciseLogHelper.makeDayStamp(for: fixture.today)
        context.insert(ExerciseLog(
            programExercise: fixture.programExercise, exerciseName: nil, date: fixture.today, dayStamp: dayStamp,
            repsBySet: [0, 0], weightsBySet: [0, 0]
        ))
        context.insert(ExerciseLog(
            programExercise: fixture.programExercise, exerciseName: nil, date: fixture.today, dayStamp: dayStamp,
            repsBySet: [8, 8], weightsBySet: [40, 40]
        ))
        try context.save()
        let store = ExerciseLogStore(modelContainer: fixture.container)

        let logs = try await store.fetchLogs(in: fixture.scope)

        #expect(logs.map(\.values.repsBySet) == [[8, 8]])
        #expect(try ModelContext(fixture.container).fetch(FetchDescriptor<ExerciseLog>()).count == 1)
    }

    @Test func fetchNormalizesStoredDatesToWholeDays() async throws {
        let fixture = try ExerciseRowFixture()
        let context = fixture.container.mainContext
        let lateEvening = fixture.today.addingTimeInterval(20 * 3600)
        context.insert(ExerciseLog(
            programExercise: fixture.programExercise, exerciseName: nil, date: lateEvening, dayStamp: 0,
            repsBySet: [3], weightsBySet: [0]
        ))
        try context.save()
        let store = ExerciseLogStore(modelContainer: fixture.container)

        let logs = try await store.fetchLogs(in: fixture.scope)

        #expect(logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
    }

    @Test func unknownProgramExerciseIsAnError() async throws {
        let fixture = try ExerciseRowFixture()
        let store = ExerciseLogStore(modelContainer: fixture.container)
        let scope = ExerciseLogScope(programExerciseID: UUID(), exerciseID: fixture.exercise.id, sharedHistory: false)

        await #expect(throws: ExerciseLogStore.StoreError.self) {
            try await store.saveLog(
                in: scope, day: fixture.today, sets: nil,
                values: ExerciseLogValues(repsBySet: [1], weightsBySet: [0], durationsBySet: [0]), keepEmpty: false
            )
        }
    }
}
