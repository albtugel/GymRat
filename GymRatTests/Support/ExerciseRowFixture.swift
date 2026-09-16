import Foundation
import SwiftData
@testable import GymRat

enum TestError: Error {
    case storeUnavailable
}

/// In-memory stand-in for the log store. `failure` makes every call throw; `failWrites` fails only
/// writes so reads (and therefore `load()`) keep working.
@MainActor
final class FakeExerciseLogStore: ExerciseLogStoreType {
    struct Entry: Equatable {
        let scope: ExerciseLogScope
        let snapshot: ExerciseLogSnapshot
    }

    private(set) var entries: [Entry] = []
    private(set) var programExerciseSets: [UUID: Int] = [:]
    var failure: (any Error)?
    var failWrites = false

    var logs: [ExerciseLogSnapshot] { entries.map(\.snapshot) }

    func fetchLogs(in scope: ExerciseLogScope) throws -> [ExerciseLogSnapshot] {
        try failIfNeeded(isWrite: false)
        return entries
            .filter { Self.matches($0.scope, scope) }
            .map(\.snapshot)
            .sorted { $0.dayStamp < $1.dayStamp }
    }

    func saveLog(
        in scope: ExerciseLogScope,
        day: Date,
        sets: Int?,
        values: ExerciseLogValues,
        keepEmpty: Bool
    ) throws -> ExerciseLogSnapshot? {
        try failIfNeeded(isWrite: true)
        let dayStamp = ExerciseLogHelper.makeDayStamp(for: day)
        entries.removeAll { Self.matches($0.scope, scope) && $0.snapshot.dayStamp == dayStamp }
        if let sets {
            programExerciseSets[scope.programExerciseID] = sets
        }
        guard values.hasValues || keepEmpty else { return nil }
        let snapshot = ExerciseLogSnapshot(id: UUID(), dayStamp: dayStamp, values: values)
        entries.append(Entry(scope: scope, snapshot: snapshot))
        return snapshot
    }

    func deleteLogs(in scope: ExerciseLogScope) throws {
        try failIfNeeded(isWrite: true)
        entries.removeAll { Self.matches($0.scope, scope) }
    }

    private static func matches(_ stored: ExerciseLogScope, _ requested: ExerciseLogScope) -> Bool {
        requested.sharedHistory
            ? stored.exerciseID == requested.exerciseID
            : stored.programExerciseID == requested.programExerciseID
    }

    private func failIfNeeded(isWrite: Bool) throws {
        if let failure { throw failure }
        if isWrite, failWrites { throw TestError.storeUnavailable }
    }
}

/// Catalog stand-in: answers only from the seeds it was given and never touches the network.
struct FakeExerciseStore: ExerciseStoreType {
    var seeds: [ExerciseRepo.ExerciseSeed] = []

    func refresh() async -> [ExerciseRepo.Exercise] { [] }

    func seedSnapshot() async -> [ExerciseRepo.ExerciseSeed] { seeds }

    func getExerciseSeed(named name: String) async -> ExerciseRepo.ExerciseSeed? {
        seeds.first { $0.name == name }
    }

    func getExerciseSeedResolvingRemote(named name: String) async -> ExerciseRepo.ExerciseSeed? {
        await getExerciseSeed(named: name)
    }

    func gifURLs(forExerciseNames names: [String]) async -> [URL] { [] }
}

/// One saved exercise in an in-memory model container plus a fake log store, ready to drive
/// `ExerciseRowViewModel` the way the row view does.
@MainActor
struct ExerciseRowFixture {
    let container: ModelContainer
    let logStore = FakeExerciseLogStore()
    let exercise: Exercise
    let programExercise: WorkoutExercise
    let today = Date().startOfDay

    var tomorrow: Date {
        AppCalendar.calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }

    var scope: ExerciseLogScope {
        ExerciseLogScope(programExerciseID: programExercise.id, exerciseID: exercise.id, sharedHistory: false)
    }

    init() throws {
        let schema = Schema(GymRatSchemaV1.models)
        container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        exercise = Exercise(name: "Test press", categoryRaw: ExerciseCategory.strength.rawValue)
        programExercise = WorkoutExercise(exercise: exercise, sets: 3)
        container.mainContext.insert(exercise)
        container.mainContext.insert(programExercise)
        try container.mainContext.save()
    }

    func makeViewModel() -> ExerciseRowViewModel {
        ExerciseRowViewModel(
            programExercise: programExercise,
            selectedDate: today,
            logStore: logStore,
            units: Units(defaults: UserDefaults(suiteName: "ExerciseRowFixture-\(UUID().uuidString)") ?? .standard),
            exerciseStore: FakeExerciseStore()
        )
    }

    /// Focuses the first reps field and types into it, leaving the row with unsaved entries.
    func enterReps(_ text: String, into viewModel: ExerciseRowViewModel) async {
        await viewModel.handleFocusChange(.reps(programExercise.id, 0))
        viewModel.updateRepsText(text, index: 0)
    }

    /// Mirrors the UI: focus, type, then move focus away, which triggers the save.
    func typeReps(_ text: String, into viewModel: ExerciseRowViewModel) async {
        await enterReps(text, into: viewModel)
        await viewModel.handleFocusChange(nil)
    }
}
