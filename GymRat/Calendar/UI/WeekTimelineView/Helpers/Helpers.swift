import Foundation

enum WeekTimelineHelpers {
    static func makeWeek(from date: Date) -> [Date] {
        let calendar = AppCalendar.calendar
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }
}
