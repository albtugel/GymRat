import Foundation
import SwiftData
import Testing
@testable import GymRat

/// Stores written by earlier App Store builds must open with their data, never through the
/// recovery path. Each test writes a store the way that build did — a plain `Schema` of its models,
/// no migration plan — and opens it with the current `PersistentStore`.
@MainActor
struct LegacyStoreMigrationTests {

    @Test func firstReleaseStoreKeepsProgramsExercisesLogsAndSchedule() throws {
        let storeURL = Self.makeStoreURL()
        defer { Self.removeFolder(containing: storeURL) }
        let ids = try Self.writeV0_1Store(at: storeURL)

        let opened = try PersistentStore.open(at: storeURL)

        #expect(opened.recovery == nil)
        let context = ModelContext(opened.container)
        let program = try #require(try context.fetch(FetchDescriptor<Program>()).first)
        #expect(program.id == ids.program)
        #expect(program.name == "Push day")
        #expect(program.colorHex == "#FF0000")
        #expect(Set(program.weekdaysRaw) == ["monday", "thursday"])
        #expect(program.exercises.sorted { $0.selectionIndex < $1.selectionIndex }.map(\.exercise.name) == ["Bench press", "Custom fly"])
        #expect(program.exercises.first { $0.id == ids.bench }?.sets == 5)

        let logs = try context.fetch(FetchDescriptor<ExerciseLog>())
        #expect(logs.map(\.id) == [ids.log])
        #expect(logs.first?.programExercise.id == ids.bench)
        #expect(logs.first?.weightsBySet == [80, 80, 85])

        let schedule = try context.fetch(FetchDescriptor<ScheduleItem>())
        #expect(schedule.map(\.program?.id) == [ids.program])

        let exercises = try context.fetch(FetchDescriptor<Exercise>())
        #expect(exercises.count == 2)
        #expect(exercises.first { $0.name == "Custom fly" }?.isCustom == true)
    }

    /// Deleting a program in the first releases cascaded its exercises but left their logs pointing
    /// at deleted rows. Migration must skip those instead of crashing on them.
    @Test func firstReleaseStoreWithOrphanedLogsMigratesTheRest() throws {
        let storeURL = Self.makeStoreURL()
        defer { Self.removeFolder(containing: storeURL) }
        let ids = try Self.writeV0_1Store(at: storeURL, addDeletedProgramWithLog: true)

        let opened = try PersistentStore.open(at: storeURL)

        #expect(opened.recovery == nil)
        let context = ModelContext(opened.container)
        #expect(try context.fetch(FetchDescriptor<Program>()).map(\.id) == [ids.program])
        #expect(try context.fetch(FetchDescriptor<ExerciseLog>()).map(\.id) == [ids.log])
    }

    @Test func renamedModelStoreFromMayToJulyMigrates() throws {
        let storeURL = Self.makeStoreURL()
        defer { Self.removeFolder(containing: storeURL) }
        typealias Old = GymRatSchemaV0_2
        let programID = UUID()
        do {
            let schema = Schema(Old.models)
            let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: storeURL)])
            let context = ModelContext(container)
            let exercise = Old.Exercise(name: "Squat", categoryRaw: "strength")
            let workout = Old.WorkoutExercise(exercise: exercise, sets: 4, selectionIndex: 1)
            let program = Old.Program(id: programID, name: "Legs", typeRaw: "strength", weekdaysRaw: ["friday"])
            context.insert(exercise)
            context.insert(program)
            program.exercises = [workout]
            context.insert(Old.ExerciseLog(programExercise: workout, exerciseName: "Squat", date: Date(), dayStamp: 20260520, repsBySet: [5, 5], weightsBySet: [100, 100]))
            context.insert(Old.ScheduleItem(program: program, date: Date()))
            try context.save()
        }

        let opened = try PersistentStore.open(at: storeURL)

        #expect(opened.recovery == nil)
        let context = ModelContext(opened.container)
        let program = try #require(try context.fetch(FetchDescriptor<Program>()).first)
        #expect(program.id == programID)
        #expect(program.exercises.map(\.sets) == [4])
        #expect(try context.fetch(FetchDescriptor<ExerciseLog>()).map(\.repsBySet) == [[5, 5]])
        #expect(try context.fetch(FetchDescriptor<ScheduleItem>()).map(\.program?.id) == [programID])
    }

    // MARK: - Helpers

    private struct V0_1IDs {
        let program: UUID
        let bench: UUID
        let log: UUID
    }

    private static func writeV0_1Store(at url: URL, addDeletedProgramWithLog: Bool = false) throws -> V0_1IDs {
        typealias Old = GymRatSchemaV0_1
        // The first releases built their container from this exact list, without a versioned schema.
        let schema = Schema([
            Old.ProgramModel.self,
            Old.ProgramExercise.self,
            Old.ExerciseModel.self,
            Old.ProgramExerciseLog.self,
            Old.ProgramAssignment.self,
            Old.DayProgramModel.self,
            Old.TimelineItem.self
        ])
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, url: url)])
        let context = ModelContext(container)

        let benchExercise = Old.ExerciseModel(name: "Bench press", categoryRaw: "strength")
        let flyExercise = Old.ExerciseModel(name: "Custom fly", categoryRaw: "strength", isCustom: true)
        let bench = Old.ProgramExercise(exercise: benchExercise, sets: 5, reps: 5, selectionIndex: 1)
        let fly = Old.ProgramExercise(exercise: flyExercise, sets: 3, reps: 12, selectionIndex: 2, sharedHistory: true)
        let program = Old.ProgramModel(name: "Push day", typeRaw: "strength", colorHex: "#FF0000", weekdaysRaw: ["monday", "thursday"])
        context.insert(benchExercise)
        context.insert(flyExercise)
        context.insert(program)
        program.exercises = [bench, fly]
        let log = Old.ProgramExerciseLog(
            programExercise: bench, exerciseName: "Bench press", date: Date(), dayStamp: 20260402,
            repsBySet: [5, 5, 5], weightsBySet: [80, 80, 85]
        )
        context.insert(log)
        context.insert(Old.ProgramAssignment(program: program, date: Date()))
        try context.save()

        if addDeletedProgramWithLog {
            let doomed = Old.ProgramModel(name: "Deleted", typeRaw: "strength")
            let doomedWorkout = Old.ProgramExercise(exercise: benchExercise, selectionIndex: 1)
            context.insert(doomed)
            doomed.exercises = [doomedWorkout]
            context.insert(Old.ProgramExerciseLog(
                programExercise: doomedWorkout, exerciseName: "Bench press", date: Date(), dayStamp: 20260403,
                repsBySet: [1], weightsBySet: [1]
            ))
            try context.save()
            context.delete(doomed)
            try context.save()
        }
        return V0_1IDs(program: program.id, bench: bench.id, log: log.id)
    }

    private static func makeStoreURL() -> URL {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("LegacyStoreMigrationTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(PersistentStore.fileName)
    }

    private static func removeFolder(containing storeURL: URL) {
        try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
    }
}
