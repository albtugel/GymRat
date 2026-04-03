import Foundation
import Observation

@Observable
@MainActor
final class TimelineViewModel {

    // MARK: - State
    private(set) var items: [TimelineItem] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let timelineService: TimelineItemServiceProtocol

    init(timelineService: TimelineItemServiceProtocol) {
        self.timelineService = timelineService
    }

    // MARK: - Intents
    func loadItems() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await timelineService.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addWorkout(title: String, date: Date) async {
        let item = makeWorkoutItem(title: title, date: date)
        await insertItem(item)
    }

    func addPersonalEvent(title: String, startDate: Date, endDate: Date) async {
        let item = makePersonalItem(title: title, startDate: startDate, endDate: endDate)
        await insertItem(item)
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - Helpers
    private func insertItem(_ item: TimelineItem) async {
        do {
            try await timelineService.insertItem(item)
            items.append(item)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func makeWorkoutItem(title: String, date: Date) -> TimelineItem {
        TimelineItem(
            title: title,
            startDate: date,
            endDate: date.addingTimeInterval(3600),
            typeRaw: TimelineItemType.workout.rawValue,
            program: nil
        )
    }

    private func makePersonalItem(title: String, startDate: Date, endDate: Date) -> TimelineItem {
        TimelineItem(
            title: title,
            startDate: startDate,
            endDate: endDate,
            typeRaw: TimelineItemType.personal.rawValue
        )
    }
}
