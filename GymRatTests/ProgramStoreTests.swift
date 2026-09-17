import Foundation
import SwiftData
import Testing
@testable import GymRat

/// The real store against an in-memory container. Assertions read back through fresh contexts or
/// the store itself; nothing relies on objects held on the main actor.
@MainActor
struct ProgramStoreTests {

    @Test func savingANewProgramStoresExercisesInOrderAndSchedulesTheWeek() async throws {
        let fixture = try Fixture()
        let program = ProgramSnapshot(
            name: "Legs",
            type: .strength,
            weekdays: [.monday, .thursday],
            exercises: [
                WorkoutExerciseSnapshot(exercise: fixture.row, sets: 4, reps: 8, selectionIndex: 2),
                WorkoutExerciseSnapshot(exercise: fixture.squat, sets: 5, reps: 5, selectionIndex: 1)
            ]
        )

        let saved = try await fixture.store.save(program)

        #expect(saved.exercises.map(\.exercise.name) == ["Squat", "Row"])
        let fetched = try await fixture.store.fetchPrograms()
        #expect(fetched.map(\.name) == ["Legs"])
        #expect(fetched.first?.weekdays == [.monday, .thursday])
        #expect(fetched.first?.exercises.map(\.sets) == [5, 4])
        #expect(try fixture.count(ScheduleItem.self) == 2)
    }

    @Test func editingReconcilesExercisesAndDropsRemovedHistory() async throws {
        let fixture = try Fixture()
        let squat = WorkoutExerciseSnapshot(exercise: fixture.squat, sets: 3, selectionIndex: 1)
        let row = WorkoutExerciseSnapshot(exercise: fixture.row, sets: 3, selectionIndex: 2)
        var program = try await fixture.store.save(ProgramSnapshot(name: "Full body", type: .strength, exercises: [squat, row]))
        _ = try await fixture.logStore.saveLog(
            in: ExerciseLogScope(programExerciseID: row.id, exerciseID: fixture.row.id, sharedHistory: false),
            day: Date(), sets: nil,
            values: ExerciseLogValues(repsBySet: [8, 8, 8], weightsBySet: [40, 40, 40], durationsBySet: [0, 0, 0]),
            keepEmpty: false
        )
        #expect(try fixture.count(ExerciseLog.self) == 1)

        var keptSquat = squat
        keptSquat.sets = 6
        program.exercises = [keptSquat]
        let saved = try await fixture.store.save(program)

        #expect(saved.exercises.map(\.exercise.name) == ["Squat"])
        #expect(saved.exercises.first?.sets == 6)
        #expect(try fixture.count(WorkoutExercise.self) == 1)
        #expect(try fixture.count(ExerciseLog.self) == 0)
    }

    @Test func deletingAProgramRemovesItsExercisesHistoryAndSchedule() async throws {
        let fixture = try Fixture()
        let squat = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1)
        let program = try await fixture.store.save(ProgramSnapshot(name: "Legs", type: .strength, weekdays: [.friday], exercises: [squat]))
        _ = try await fixture.logStore.saveLog(
            in: ExerciseLogScope(programExerciseID: squat.id, exerciseID: fixture.squat.id, sharedHistory: false),
            day: Date(), sets: nil,
            values: ExerciseLogValues(repsBySet: [5], weightsBySet: [100], durationsBySet: [0]),
            keepEmpty: false
        )

        try await fixture.store.deleteProgram(id: program.id)

        #expect(try fixture.count(Program.self) == 0)
        #expect(try fixture.count(WorkoutExercise.self) == 0)
        #expect(try fixture.count(ExerciseLog.self) == 0)
        #expect(try fixture.count(ScheduleItem.self) == 0)
        #expect(try fixture.count(Exercise.self) == 2)
    }

    @Test func removingASharedExerciseMovesItsHistoryToTheProgramStillSharingIt() async throws {
        let fixture = try Fixture()
        let sharedA = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1, sharedHistory: true)
        let sharedB = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1, sharedHistory: true)
        var programA = try await fixture.store.save(ProgramSnapshot(name: "A", type: .strength, exercises: [sharedA]))
        _ = try await fixture.store.save(ProgramSnapshot(name: "B", type: .strength, exercises: [sharedB]))
        try await fixture.logSquat(on: sharedA, reps: 5)

        programA.exercises = []
        _ = try await fixture.store.save(programA)

        let historyInB = try await fixture.logStore.fetchLogs(in: fixture.sharedScope(for: sharedB))
        #expect(historyInB.map(\.values.repsBySet) == [[5]])
        #expect(try fixture.logOwners() == [sharedB.id])
    }

    @Test func deletingAProgramKeepsHistorySharedWithAnotherProgram() async throws {
        let fixture = try Fixture()
        let sharedA = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1, sharedHistory: true)
        let sharedB = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1, sharedHistory: true)
        let programA = try await fixture.store.save(ProgramSnapshot(name: "A", type: .strength, exercises: [sharedA]))
        _ = try await fixture.store.save(ProgramSnapshot(name: "B", type: .strength, exercises: [sharedB]))
        try await fixture.logSquat(on: sharedA, reps: 7)

        try await fixture.store.deleteProgram(id: programA.id)

        let historyInB = try await fixture.logStore.fetchLogs(in: fixture.sharedScope(for: sharedB))
        #expect(historyInB.map(\.values.repsBySet) == [[7]])
        #expect(try fixture.logOwners() == [sharedB.id])
    }

    /// Another program using the same exercise without sharing history never showed these logs.
    @Test func historyIsDroppedWhenNoOtherProgramSharesIt() async throws {
        let fixture = try Fixture()
        let squatA = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1, sharedHistory: false)
        let squatB = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1, sharedHistory: false)
        let programA = try await fixture.store.save(ProgramSnapshot(name: "A", type: .strength, exercises: [squatA]))
        _ = try await fixture.store.save(ProgramSnapshot(name: "B", type: .strength, exercises: [squatB]))
        try await fixture.logSquat(on: squatA, reps: 3)

        try await fixture.store.deleteProgram(id: programA.id)

        #expect(try fixture.count(ExerciseLog.self) == 0)
        #expect(try fixture.count(WorkoutExercise.self) == 1)
    }

    /// Two sharing program exercises leaving together must not hand the history to each other.
    @Test func sharedExercisesLeavingTogetherTakeTheirHistoryAlong() async throws {
        let fixture = try Fixture()
        let first = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1, sharedHistory: true)
        let second = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 2, sharedHistory: true)
        let program = try await fixture.store.save(ProgramSnapshot(name: "A", type: .strength, exercises: [first, second]))
        try await fixture.logSquat(on: first, reps: 4)

        try await fixture.store.deleteProgram(id: program.id)

        #expect(try fixture.count(ExerciseLog.self) == 0)
        #expect(try fixture.count(WorkoutExercise.self) == 0)
    }

    @Test func reorderingRewritesPositions() async throws {
        let fixture = try Fixture()
        let squat = WorkoutExerciseSnapshot(exercise: fixture.squat, selectionIndex: 1)
        let row = WorkoutExerciseSnapshot(exercise: fixture.row, selectionIndex: 2)
        let program = try await fixture.store.save(ProgramSnapshot(name: "Legs", type: .strength, exercises: [squat, row]))

        try await fixture.store.reorderExercises(programID: program.id, orderedExerciseIDs: [row.id, squat.id])

        let fetched = try await fixture.store.fetchPrograms().first
        #expect(fetched?.exercises.map(\.exercise.name) == ["Row", "Squat"])
        #expect(fetched?.exercises.map(\.selectionIndex) == [1, 2])
    }

    @Test func sharingHistoryMarksEveryProgramExerciseOfTheExercise() async throws {
        let fixture = try Fixture()
        _ = try await fixture.store.save(ProgramSnapshot(name: "A", type: .strength, exercises: [WorkoutExerciseSnapshot(exercise: fixture.squat)]))
        _ = try await fixture.store.save(ProgramSnapshot(name: "B", type: .strength, exercises: [WorkoutExerciseSnapshot(exercise: fixture.squat), WorkoutExerciseSnapshot(exercise: fixture.row)]))

        try await fixture.store.shareHistory(exerciseID: fixture.squat.id)

        let programs = try await fixture.store.fetchPrograms()
        let squats = programs.flatMap(\.exercises).filter { $0.exercise.id == fixture.squat.id }
        #expect(squats.count == 2)
        #expect(squats.allSatisfy { $0.sharedHistory })
        let rows = programs.flatMap(\.exercises).filter { $0.exercise.id == fixture.row.id }
        #expect(rows.allSatisfy { !$0.sharedHistory })
    }

    @Test func savingWithAnUnknownExerciseFails() async throws {
        let fixture = try Fixture()
        let unknown = ExerciseSnapshot(name: "Not stored", category: .strength)

        await #expect(throws: ProgramStore.StoreError.self) {
            try await fixture.store.save(ProgramSnapshot(name: "X", type: .strength, exercises: [WorkoutExerciseSnapshot(exercise: unknown)]))
        }
    }

    // MARK: - Fixture

    @MainActor
    private struct Fixture {
        let container: ModelContainer
        let store: ProgramStore
        let logStore: ExerciseLogStore
        let squat = ExerciseSnapshot(name: "Squat", category: .strength)
        let row = ExerciseSnapshot(name: "Row", category: .strength)

        init() throws {
            let schema = PersistentStore.schema
            container = try ModelContainer(
                for: schema,
                configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
            )
            store = ProgramStore(modelContainer: container)
            logStore = ExerciseLogStore(modelContainer: container)
            let context = container.mainContext
            context.insert(Exercise(id: squat.id, name: squat.name, categoryRaw: squat.category.rawValue))
            context.insert(Exercise(id: row.id, name: row.name, categoryRaw: row.category.rawValue))
            try context.save()
        }

        func count<T: PersistentModel>(_ type: T.Type) throws -> Int {
            try ModelContext(container).fetch(FetchDescriptor<T>()).count
        }

        func sharedScope(for workout: WorkoutExerciseSnapshot) -> ExerciseLogScope {
            ExerciseLogScope(programExerciseID: workout.id, exerciseID: workout.exercise.id, sharedHistory: true)
        }

        func logSquat(on workout: WorkoutExerciseSnapshot, reps: Int) async throws {
            _ = try await logStore.saveLog(
                in: ExerciseLogScope(programExerciseID: workout.id, exerciseID: workout.exercise.id, sharedHistory: false),
                day: Date(), sets: nil,
                values: ExerciseLogValues(repsBySet: [reps], weightsBySet: [0], durationsBySet: [0]),
                keepEmpty: false
            )
        }

        /// Program exercise ids the stored logs belong to.
        func logOwners() throws -> [UUID] {
            try ModelContext(container).fetch(FetchDescriptor<ExerciseLog>()).map(\.programExercise.id)
        }
    }
}
