import Foundation
import SwiftData

/// Carries a store from `GymRatSchemaV0_1` (the first App Store releases) to `GymRatSchemaV0_2`.
///
/// The two versions name every entity differently, which inference sees as "drop the old tables,
/// create empty new ones". So the stage reads the old rows into plain values before the store is
/// migrated (`willMigrate`) and writes them into the new entities afterwards (`didMigrate`), keeping
/// every id so references survive.
///
/// Old releases could leave rows pointing at deleted objects (a log whose program exercise was
/// removed with its program). Reading such a reference crashes, so relationships are only followed
/// through fetches that filter on the target's id; orphaned rows are skipped, never dereferenced.
/// Unused `DayProgramModel` / `TimelineItem` rows are not carried over; V2 drops those entities.
enum LegacyStoreMigration {
    static var stage: MigrationStage {
        .custom(
            fromVersion: GymRatSchemaV0_1.self,
            toVersion: GymRatSchemaV0_2.self,
            willMigrate: { context in
                handoff.store(try readSnapshot(from: context))
            },
            didMigrate: { context in
                guard let snapshot = handoff.take() else { return }
                try write(snapshot, into: context)
            }
        )
    }

    // MARK: - Snapshot

    struct Snapshot: Equatable {
        struct Exercise: Equatable {
            let id: UUID
            let name: String
            let categoryRaw: String
            let isCustom: Bool
        }

        struct WorkoutExercise: Equatable {
            let id: UUID
            let exerciseID: UUID
            let sets: Int
            let reps: Int
            let selectionIndex: Int
            let sharedHistory: Bool
        }

        struct Program: Equatable {
            let id: UUID
            let name: String
            let typeRaw: String
            let colorHex: String?
            let weekdaysRaw: [String]
            let exerciseIDs: [UUID]
        }

        struct Log: Equatable {
            let id: UUID
            let programExerciseID: UUID
            let exerciseName: String?
            let date: Date
            let dayStamp: Int
            let repsBySet: [Int]
            let weightsBySet: [Double]
            let durationsBySet: [Int]
        }

        struct ScheduleItem: Equatable {
            let id: UUID
            let programID: UUID
            let date: Date
        }

        var exercises: [Exercise] = []
        var workoutExercises: [WorkoutExercise] = []
        var programs: [Program] = []
        var logs: [Log] = []
        var scheduleItems: [ScheduleItem] = []
    }

    private typealias Old = GymRatSchemaV0_1
    private typealias New = GymRatSchemaV0_2

    static func readSnapshot(from context: ModelContext) throws -> Snapshot {
        var snapshot = Snapshot()

        snapshot.exercises = try context.fetch(FetchDescriptor<Old.ExerciseModel>()).map {
            .init(id: $0.id, name: $0.name, categoryRaw: $0.categoryRaw, isCustom: $0.isCustom)
        }
        let exerciseIDs = snapshot.exercises.map(\.id)

        let workouts = try context.fetch(FetchDescriptor<Old.ProgramExercise>(
            predicate: #Predicate { exerciseIDs.contains($0.exercise.id) }
        ))
        snapshot.workoutExercises = workouts.map {
            .init(
                id: $0.id,
                exerciseID: $0.exercise.id,
                sets: $0.sets,
                reps: $0.reps,
                selectionIndex: $0.selectionIndex,
                sharedHistory: $0.sharedHistory
            )
        }
        let workoutIDs = snapshot.workoutExercises.map(\.id)
        let liveWorkouts = Set(workouts.map(\.persistentModelID))

        snapshot.programs = try context.fetch(FetchDescriptor<Old.ProgramModel>()).map { program in
            .init(
                id: program.id,
                name: program.name,
                typeRaw: program.typeRaw,
                colorHex: program.colorHex,
                weekdaysRaw: program.weekdaysRaw,
                exerciseIDs: program.exercises
                    .filter { liveWorkouts.contains($0.persistentModelID) }
                    .map(\.id)
            )
        }
        let programIDs = snapshot.programs.map(\.id)

        snapshot.logs = try context.fetch(FetchDescriptor<Old.ProgramExerciseLog>(
            predicate: #Predicate { workoutIDs.contains($0.programExercise.id) }
        )).map {
            .init(
                id: $0.id,
                programExerciseID: $0.programExercise.id,
                exerciseName: $0.exerciseName,
                date: $0.date,
                dayStamp: $0.dayStamp,
                repsBySet: $0.repsBySet,
                weightsBySet: $0.weightsBySet,
                durationsBySet: $0.durationsBySet
            )
        }

        snapshot.scheduleItems = try context.fetch(FetchDescriptor<Old.ProgramAssignment>(
            predicate: #Predicate { programIDs.contains($0.program.id) }
        )).map {
            .init(id: $0.id, programID: $0.program.id, date: $0.date)
        }

        AppLog.persistence.notice(
            "Legacy store read: \(snapshot.programs.count) programs, \(snapshot.workoutExercises.count) program exercises, \(snapshot.logs.count) logs"
        )
        return snapshot
    }

    static func write(_ snapshot: Snapshot, into context: ModelContext) throws {
        var exercises: [UUID: New.Exercise] = [:]
        for row in snapshot.exercises {
            let exercise = New.Exercise(id: row.id, name: row.name, categoryRaw: row.categoryRaw, isCustom: row.isCustom)
            context.insert(exercise)
            exercises[row.id] = exercise
        }

        var workouts: [UUID: New.WorkoutExercise] = [:]
        for row in snapshot.workoutExercises {
            guard let exercise = exercises[row.exerciseID] else { continue }
            let workout = New.WorkoutExercise(
                id: row.id,
                exercise: exercise,
                sets: row.sets,
                reps: row.reps,
                selectionIndex: row.selectionIndex,
                sharedHistory: row.sharedHistory
            )
            context.insert(workout)
            workouts[row.id] = workout
        }

        var programs: [UUID: New.Program] = [:]
        for row in snapshot.programs {
            let program = New.Program(
                id: row.id,
                name: row.name,
                typeRaw: row.typeRaw,
                colorHex: row.colorHex,
                weekdaysRaw: row.weekdaysRaw
            )
            context.insert(program)
            program.exercises = row.exerciseIDs.compactMap { workouts[$0] }
            programs[row.id] = program
        }

        for row in snapshot.logs {
            guard let workout = workouts[row.programExerciseID] else { continue }
            context.insert(New.ExerciseLog(
                id: row.id,
                programExercise: workout,
                exerciseName: row.exerciseName,
                date: row.date,
                dayStamp: row.dayStamp,
                repsBySet: row.repsBySet,
                weightsBySet: row.weightsBySet,
                durationsBySet: row.durationsBySet
            ))
        }

        for row in snapshot.scheduleItems {
            guard let program = programs[row.programID] else { continue }
            context.insert(New.ScheduleItem(id: row.id, program: program, date: row.date))
        }

        try context.save()
        AppLog.persistence.notice("Legacy store copied into schema 0.2")
    }

    // MARK: - Handoff

    /// The snapshot has to outlive the store swap between the two callbacks.
    private static let handoff = Handoff()

    private final class Handoff: @unchecked Sendable {
        private let lock = NSLock()
        private var snapshot: Snapshot?

        func store(_ value: Snapshot) {
            lock.withLock { snapshot = value }
        }

        func take() -> Snapshot? {
            lock.withLock {
                defer { snapshot = nil }
                return snapshot
            }
        }
    }
}
