import Foundation
import Testing
@testable import GymRat

/// Failed writes must never be silent: the user keeps their entries, sees an error, and a retry writes them.
@MainActor
struct ExerciseRowViewModelTests {

    @Test func failedSaveKeepsEntriesAndReportsError() async throws {
        let fixture = try ExerciseRowFixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.logStore.failure = TestError.storeUnavailable

        await fixture.typeReps("10", into: viewModel)

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasUnsavedChanges)
        #expect(viewModel.repsText(at: 0) == "10")
        #expect(fixture.logStore.logs.isEmpty)
    }

    @Test func retryAfterFailureWritesTheLog() async throws {
        let fixture = try ExerciseRowFixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.logStore.failure = TestError.storeUnavailable
        await fixture.typeReps("10", into: viewModel)

        fixture.logStore.failure = nil
        await viewModel.saveIfNeeded()

        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.hasUnsavedChanges)
        #expect(fixture.logStore.logs.map(\.values.repsBySet) == [[10, 0, 0]])
        #expect(fixture.logStore.logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
    }

    @Test func entriesFromFailedSaveSurviveSwitchingDays() async throws {
        let fixture = try ExerciseRowFixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.logStore.failure = TestError.storeUnavailable
        await fixture.typeReps("10", into: viewModel)

        fixture.logStore.failure = nil
        await viewModel.updateSelectedDate(fixture.tomorrow)

        #expect(viewModel.errorMessage == nil)
        #expect(fixture.logStore.logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
        #expect(fixture.logStore.logs.map(\.values.repsBySet) == [[10, 0, 0]])
    }

    @Test func returningToTheDayRestoresUnsavedEntries() async throws {
        let fixture = try ExerciseRowFixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.logStore.failure = TestError.storeUnavailable
        await fixture.typeReps("10", into: viewModel)

        fixture.logStore.failWrites = true
        fixture.logStore.failure = nil
        await viewModel.updateSelectedDate(fixture.tomorrow)
        #expect(viewModel.repsText(at: 0) == "")
        await viewModel.updateSelectedDate(fixture.today)

        #expect(viewModel.repsText(at: 0) == "10")
        #expect(viewModel.hasUnsavedChanges)
        #expect(viewModel.errorMessage != nil)
    }

    @Test func loadFailureReportsError() async throws {
        let fixture = try ExerciseRowFixture()
        fixture.logStore.failure = TestError.storeUnavailable
        let viewModel = fixture.makeViewModel()

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }

    @Test func previousDayValuesAreShownAsHistory() async throws {
        let fixture = try ExerciseRowFixture()
        let yesterday = AppCalendar.calendar.date(byAdding: .day, value: -1, to: fixture.today) ?? fixture.today
        _ = try fixture.logStore.saveLog(
            in: fixture.scope,
            day: yesterday,
            sets: nil,
            values: ExerciseLogValues(repsBySet: [12, 10], weightsBySet: [50, 50], durationsBySet: [0, 0]),
            keepEmpty: false
        )
        let viewModel = fixture.makeViewModel()

        await viewModel.load()

        #expect(viewModel.previousRepsText(at: 0) == "12")
        #expect(viewModel.previousWeightText(at: 1) == "50")
        #expect(viewModel.setsText() == "2")
        #expect(viewModel.repsText(at: 0) == "")
    }
}
