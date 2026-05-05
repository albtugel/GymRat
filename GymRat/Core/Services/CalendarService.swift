import EventKit
import Foundation

@MainActor
final class CalendarService: CalendarServiceType {
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

    func fetchEvents(start: Date, end: Date) async throws -> [Event] {
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: predicate).map {
            Event(
                title: $0.title,
                startDate: $0.startDate,
                endDate: $0.endDate,
                typeRaw: EventType.externalCalendar.rawValue
            )
        }
    }

    func addEvent(item: Event) async throws {
        let event = EKEvent(eventStore: store)
        event.title = item.title
        event.startDate = item.startDate
        event.endDate = item.endDate
        event.calendar = store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent)
    }
}
