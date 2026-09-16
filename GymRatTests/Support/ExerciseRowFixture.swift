import Foundation
import SwiftData
@testable import GymRat

enum TestError: Error {
    case storeUnavailable
}

/// In-memory stand-in for the SwiftData-backed log service. `failure` makes every call throw;
/// `failWrites` fails only writes so reads (and therefore `load()`) keep working.
@MainActor
final class FakeExerciseLogService: ExerciseLogServiceType {
    var logs: [ExerciseLog] = []
    var failure: (any Error)?
    var failWrites = false

    func fetchLogs(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool) async throws -> [ExerciseLog] {
        try failIfNeeded(isWrite: false)
        return logs.filter { $0.programExercise.id == programExerciseId }
    }

    func fetchLog(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool, dayStamp: Int) async throws -> ExerciseLog? {
        try failIfNeeded(isWrite: false)
        return logs.first { $0.programExercise.id == programExerciseId && $0.dayStamp == dayStamp }
    }

    func insertLog(_ log: ExerciseLog) async throws {
        try failIfNeeded(isWrite: true)
        logs.append(log)
    }

    func deleteLog(_ log: ExerciseLog) async throws {
        try failIfNeeded(isWrite: true)
        logs.removeAll { $0.id == log.id }
    }

    func saveChanges() async throws {
        try failIfNeeded(isWrite: true)
    }

    private func failIfNeeded(isWrite: Bool) throws {
        if let failure { throw failure }
        if isWrite, failWrites { throw TestError.storeUnavailable }
    }
}

/// One exercise in an in-memory model container plus a fake log service, ready to drive
/// `ExerciseRowViewModel` the way the row view does.
@MainActor
struct ExerciseRowFixture {
    let container: ModelContainer
    let service = FakeExerciseLogService()
    let programExercise: WorkoutExercise
    let today = Date().startOfDay

    var tomorrow: Date {
        AppCalendar.calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }

    init() throws {
        let schema = Schema(GymRatSchemaV1.models)
        container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        let exercise = Exercise(name: "Test press", categoryRaw: ExerciseCategory.strength.rawValue)
        programExercise = WorkoutExercise(exercise: exercise, sets: 3)
        container.mainContext.insert(exercise)
        container.mainContext.insert(programExercise)
    }

    func makeViewModel() -> ExerciseRowViewModel {
        ExerciseRowViewModel(
            programExercise: programExercise,
            selectedDate: today,
            logService: service,
            units: Units(defaults: UserDefaults(suiteName: "ExerciseRowFixture-\(UUID().uuidString)") ?? .standard),
            exerciseStore: ExerciseRepo.shared
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
