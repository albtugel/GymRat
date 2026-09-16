import Foundation
import Testing
@testable import GymRat

/// Changing the visible day must write what was typed into the previous day first.
@MainActor
struct WeekViewModelTests {

    @Test func selectingADayFlushesVisibleRowsFirst() async throws {
        let fixture = try ExerciseRowFixture()
        let coordinator = ExerciseLogSaveCoordinator()
        let viewModel = WeekViewModel(initialDate: fixture.today, saveCoordinator: coordinator)
        let row = fixture.makeViewModel()
        await row.load()
        coordinator.register(row)
        await fixture.enterReps("8", into: row)

        await viewModel.selectDate(fixture.tomorrow)

        #expect(viewModel.selectedDate == fixture.tomorrow)
        #expect(fixture.service.logs.map(\.dayStamp) == [ExerciseLogHelper.makeDayStamp(for: fixture.today)])
    }

    @Test func movingTheWeekFlushesVisibleRowsFirst() async throws {
        let fixture = try ExerciseRowFixture()
        let coordinator = ExerciseLogSaveCoordinator()
        let viewModel = WeekViewModel(initialDate: fixture.today, saveCoordinator: coordinator)
        let row = fixture.makeViewModel()
        await row.load()
        coordinator.register(row)
        await fixture.enterReps("8", into: row)
        let previousWeekStart = viewModel.weekStartDate

        await viewModel.moveWeek(by: 1)

        #expect(viewModel.weekStartDate > previousWeekStart)
        #expect(fixture.service.logs.map(\.repsBySet) == [[8, 0, 0]])
    }
}
