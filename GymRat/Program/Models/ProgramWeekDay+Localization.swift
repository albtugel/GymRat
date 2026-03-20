import Foundation

extension ProgramWeekDay {
    var localizedTitle: String {
        switch self {
        case .monday: return String(localized: "weekday_monday")
        case .tuesday: return String(localized: "weekday_tuesday")
        case .wednesday: return String(localized: "weekday_wednesday")
        case .thursday: return String(localized: "weekday_thursday")
        case .friday: return String(localized: "weekday_friday")
        case .saturday: return String(localized: "weekday_saturday")
        case .sunday: return String(localized: "weekday_sunday")
        }
    }

    var localizedShortTitle: String {
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
}
