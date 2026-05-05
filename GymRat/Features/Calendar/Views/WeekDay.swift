import Foundation

enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .monday: return String(localized: "weekday_mon_short")
        case .tuesday: return String(localized: "weekday_tue_short")
        case .wednesday: return String(localized: "weekday_wed_short")
        case .thursday: return String(localized: "weekday_thu_short")
        case .friday: return String(localized: "weekday_fri_short")
        case .saturday: return String(localized: "weekday_sat_short")
        case .sunday: return String(localized: "weekday_sun_short")
        }
    }

    static func from(date: Date) -> Weekday {
        let weekday = AppCalendar.calendar.component(.weekday, from: date)
        return Weekday(rawValue: weekday == 1 ? 7 : weekday - 1) ?? .monday
    }
}
