import Foundation

enum ProgramWeekDay: String, CaseIterable, Identifiable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: String { rawValue.capitalized }

    // Internal numbering: Monday = 1 ... Sunday = 7
    var calendarNumber: Int {
        switch self {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }

    // Calendar(.weekday) numbering: Sunday = 1 ... Saturday = 7
    var systemWeekdayNumber: Int {
        (calendarNumber % 7) + 1
    }

    static func from(date: Date) -> ProgramWeekDay? {
        let weekday = AppCalendar.calendar.component(.weekday, from: date)
        let internalNumber = weekday == 1 ? 7 : weekday - 1
        return ProgramWeekDay.allCases.first { $0.calendarNumber == internalNumber }
    }
}
