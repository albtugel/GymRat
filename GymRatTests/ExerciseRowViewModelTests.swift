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
        fixture.service.failure = TestError.storeUnavailable

        fixture.typeReps("10", into: viewModel)

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.hasUnsavedChanges)
        #expect(viewModel.repsText(at: 0) == "10")
        #expect(fixture.service.logs.isEmpty)
    }

    @Test func retryAfterFailureWritesTheLog() async throws {
        let fixture = try ExerciseRowFixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.service.failure = TestError.storeUnavailable
        fixture.typeReps("10", into: viewModel)

        fixture.service.failure = nil
        viewModel.saveIfNeeded()

        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.hasUnsavedChanges)
        #expect(fixture.service.logs.map(\.repsBySet) == [[10, 0, 0]])
        #expect(fixture.service.logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
    }

    @Test func entriesFromFailedSaveSurviveSwitchingDays() async throws {
        let fixture = try ExerciseRowFixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.service.failure = TestError.storeUnavailable
        fixture.typeReps("10", into: viewModel)

        fixture.service.failure = nil
        await viewModel.updateSelectedDate(fixture.tomorrow)

        #expect(viewModel.errorMessage == nil)
        #expect(fixture.service.logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
        #expect(fixture.service.logs.map(\.repsBySet) == [[10, 0, 0]])
    }

    @Test func returningToTheDayRestoresUnsavedEntries() async throws {
        let fixture = try ExerciseRowFixture()
        let viewModel = fixture.makeViewModel()
        await viewModel.load()
        fixture.service.failure = TestError.storeUnavailable
        fixture.typeReps("10", into: viewModel)

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
        let fixture = try ExerciseRowFixture()
        fixture.service.failure = TestError.storeUnavailable
        let viewModel = fixture.makeViewModel()

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }
}
