import Foundation
import SwiftData
import Testing
@testable import GymRat

/// Failed writes must never be silent: the user keeps their entries, sees an error, and a retry writes them.
@MainActor
struct ExerciseRowViewModelTests {

    @Test func failedSaveKeepsEntriesAndReportsError() async throws {
        let fixture = try Fixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.service.failure = TestError.storeUnavailable

        await fixture.typeReps("10", into: viewModel)

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasUnsavedChanges)
        #expect(viewModel.repsText(at: 0) == "10")
        #expect(fixture.service.logs.isEmpty)
    }

    @Test func retryAfterFailureWritesTheLog() async throws {
        let fixture = try Fixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.service.failure = TestError.storeUnavailable
        await fixture.typeReps("10", into: viewModel)

        fixture.service.failure = nil
        await viewModel.retrySave()

        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.hasUnsavedChanges)
        #expect(fixture.service.logs.map(\.repsBySet) == [[10, 0, 0]])
        #expect(fixture.service.logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
    }

    @Test func entriesFromFailedSaveSurviveSwitchingDays() async throws {
        let fixture = try Fixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.service.failure = TestError.storeUnavailable
        await fixture.typeReps("10", into: viewModel)

        fixture.service.failure = nil
        await viewModel.updateSelectedDate(fixture.tomorrow)

        #expect(viewModel.errorMessage == nil)
        #expect(fixture.service.logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
        #expect(fixture.service.logs.map(\.repsBySet) == [[10, 0, 0]])
    }

    @Test func returningToTheDayRestoresUnsavedEntries() async throws {
        let fixture = try Fixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.service.failure = TestError.storeUnavailable
        await fixture.typeReps("10", into: viewModel)

        fixture.service.failWrites = true
        fixture.service.failure = nil
        await viewModel.updateSelectedDate(fixture.tomorrow)
        #expect(viewModel.repsText(at: 0) == "")
        await viewModel.updateSelectedDate(fixture.today)

        #expect(viewModel.repsText(at: 0) == "10")
        #expect(viewModel.hasUnsavedChanges)
        #expect(viewModel.errorMessage != nil)
    }

    @Test func loadFailureReportsError() async throws {
        let fixture = try Fixture()
        fixture.service.failure = TestError.storeUnavailable
        let viewModel = fixture.makeViewModel()

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Fixture

    private enum TestError: Error {
        case storeUnavailable
    }

    private final class FakeExerciseLogService: ExerciseLogServiceType {
        var logs: [ExerciseLog] = []
        /// Thrown by every call while set.
        var failure: (any Error)?
        /// Fails only writes, so reads (and therefore `load()`) keep working.
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

    private struct Fixture {
        let container: ModelContainer
        let service = FakeExerciseLogService()
        let programExercise: WorkoutExercise
        let today = Date().startOfDay
        var tomorrow: Date { AppCalendar.calendar.date(byAdding: .day, value: 1, to: today) ?? today }

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
                units: Units(defaults: UserDefaults(suiteName: "ExerciseRowViewModelTests-\(UUID().uuidString)") ?? .standard),
                exerciseStore: ExerciseRepo.shared
            )
        }

        /// Mirrors the UI: focus a reps field, type, then move focus away, which triggers the save.
        func typeReps(_ text: String, into viewModel: ExerciseRowViewModel) async {
            await viewModel.handleFocusChange(.reps(programExercise.id, 0))
            viewModel.updateRepsText(text, index: 0)
            await viewModel.handleFocusChange(nil)
        }
    }
}
