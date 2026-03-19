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

    var dayShortName: String {
        let f = DateFormatter()
        f.calendar = AppCalendar.calendar
        f.locale = .current
        f.dateFormat = "EEE"
        return f.string(from: self)
    }

    var dayNumberString: String {
        let f = DateFormatter()
        f.calendar = AppCalendar.calendar
        f.locale = .current
        f.dateFormat = "d"
        return f.string(from: self)
    }

    var monthNameYear: String {
        let f = DateFormatter()
        f.calendar = AppCalendar.calendar
        f.locale = .current
        f.dateFormat = "LLLL yyyy"
        let raw = f.string(from: self)
        return raw.capitalized(with: .current)
    }
}
