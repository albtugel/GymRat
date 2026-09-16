import Foundation

extension Date {
    var startOfDay: Date {
        AppCalendar.calendar.startOfDay(for: self)
    }

    var startOfWeek: Date {
        AppCalendar.calendar.dateInterval(of: .weekOfYear, for: self)?.start ?? self
    }

    func isSameDay(as other: Date) -> Bool {
        AppCalendar.calendar.isDate(self, inSameDayAs: other)
    }

    var isToday: Bool {
        AppCalendar.calendar.isDateInToday(self)
    }
}
