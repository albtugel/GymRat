import Foundation

enum WeekDay: Int, CaseIterable, Identifiable, Codable {
    case Monday = 1
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    case Sunday

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .Monday: return String(localized: "weekday_mon_short")
        case .Tuesday: return String(localized: "weekday_tue_short")
        case .Wednesday: return String(localized: "weekday_wed_short")
        case .Thursday: return String(localized: "weekday_thu_short")
        case .Friday: return String(localized: "weekday_fri_short")
        case .Saturday: return String(localized: "weekday_sat_short")
        case .Sunday: return String(localized: "weekday_sun_short")
        }
    }

    /// 🔥 ЕДИНСТВЕННЫЙ правильный маппинг Date → WeekDay
    static func from(date: Date) -> WeekDay {
        let weekday = AppCalendar.calendar.component(.weekday, from: date)
        // weekday: 1 = Sunday → 7
        return WeekDay(rawValue: weekday == 1 ? 7 : weekday - 1)!
    }
}
