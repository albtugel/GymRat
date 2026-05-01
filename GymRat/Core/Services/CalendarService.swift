import EventKit
import Foundation

@MainActor
final class CalendarService: CalendarServiceProtocol {
    private let store = EKEventStore()

    func requestAccess() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            if #available(iOS 17, *) {
                store.requestFullAccessToEvents { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: granted)
                }
            } else {
                store.requestAccess(to: .event) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    func fetchEvents(start: Date, end: Date) async throws -> [TimelineItem] {
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: predicate).map {
            TimelineItem(
                title: $0.title,
                startDate: $0.startDate,
                endDate: $0.endDate,
                typeRaw: TimelineItemType.externalCalendar.rawValue
            )
        }
    }

    func addEvent(item: TimelineItem) async throws {
        let event = EKEvent(eventStore: store)
        event.title = item.title
        event.startDate = item.startDate
        event.endDate = item.endDate
        event.calendar = store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent)
    }
}
