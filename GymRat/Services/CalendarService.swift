import EventKit

class CalendarService {
    let store = EKEventStore()

    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17, *) {
            store.requestFullAccessToEvents { granted, _ in
                completion(granted)
            }
        } else {
            store.requestAccess(to: .event) { granted, _ in
                completion(granted)
            }
        }
    }

    func fetchEvents(start: Date, end: Date) -> [TimelineItem] {
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: predicate).map {
            TimelineItem(title: $0.title, startDate: $0.startDate, endDate: $0.endDate, type: .externalCalendar)
        }
    }

    func addEvent(item: TimelineItem) throws {
        let event = EKEvent(eventStore: store)
        event.title = item.title
        event.startDate = item.startDate
        event.endDate = item.endDate
        event.calendar = store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent)
    }
}
