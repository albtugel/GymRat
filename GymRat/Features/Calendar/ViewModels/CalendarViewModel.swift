import Foundation
import Observation

@Observable
@MainActor
final class CalendarViewModel {


    private(set) var items: [Event] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?


    private let timelineService: TimelineServiceType

    init(timelineService: TimelineServiceType) {
        self.timelineService = timelineService
    }


    func loadItems() {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try timelineService.fetchItems()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addWorkout(title: String, date: Date) {
        let item = makeWorkoutItem(title: title, date: date)
        insertItem(item)
    }

    func addPersonalEvent(title: String, startDate: Date, endDate: Date) {
        let item = makePersonalItem(title: title, startDate: startDate, endDate: endDate)
        insertItem(item)
    }

    func dismissError() {
        errorMessage = nil
    }


    static func makeItemColor(for item: Event) -> TimelineColor {
        switch TimelineMapper.type(for: item) {
        case .workout:
            return .workout
        case .personal:
            return .personal
        case .externalCalendar:
            return .externalCalendar
        }
    }

    private func insertItem(_ item: Event) {
        do {
            try timelineService.insertItem(item)
            items.append(item)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func makeWorkoutItem(title: String, date: Date) -> Event {
        Event(
            title: title,
            startDate: date,
            endDate: date.addingTimeInterval(3600),
            typeRaw: EventType.workout.rawValue,
            program: nil
        )
    }

    private func makePersonalItem(title: String, startDate: Date, endDate: Date) -> Event {
        Event(
            title: title,
            startDate: startDate,
            endDate: endDate,
            typeRaw: EventType.personal.rawValue
        )
    }
}
