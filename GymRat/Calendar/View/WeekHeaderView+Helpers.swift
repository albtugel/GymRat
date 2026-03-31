import Foundation

extension WeekHeaderView {
    var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        return cal
    }

    var monthTitle: String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = .current
        f.dateFormat = "LLLL yyyy"
        return f.string(from: weekStartDate)
    }

    func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = .current
        f.dateFormat = "d"
        return f.string(from: date)
    }

    func weekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = .current
        f.dateFormat = "E"
        return f.string(from: date)
    }

    func moveWeek(by value: Int) {
        guard let newStart = calendar.date(byAdding: .weekOfYear, value: value, to: weekStartDate) else { return }
        weekStartDate = newStart
        selectedDate = newStart
    }
}
