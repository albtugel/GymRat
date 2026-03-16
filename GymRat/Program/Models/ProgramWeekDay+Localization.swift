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
}
