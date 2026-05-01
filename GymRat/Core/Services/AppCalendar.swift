import Foundation

enum AppCalendar {
    static let calendar: Calendar = {
        var cal = Calendar(identifier: .iso8601)
        cal.firstWeekday = 2 // Monday
        cal.timeZone = .autoupdatingCurrent
        return cal
    }()
}
