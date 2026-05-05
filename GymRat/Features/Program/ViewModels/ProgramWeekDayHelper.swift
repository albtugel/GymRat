import Foundation

enum ProgramWeekdayHelper {
    static func calendarNumber(for day: ProgramWeekday) -> Int {
        switch day {
        case .monday: return 1
        case .tuesday: return 2
        case .wednesday: return 3
        case .thursday: return 4
        case .friday: return 5
        case .saturday: return 6
        case .sunday: return 7
        }
    }

    static func systemWeekdayNumber(for day: ProgramWeekday) -> Int {
        (calendarNumber(for: day) % 7) + 1
    }

    static func from(calendarNumber: Int) -> ProgramWeekday? {
        switch calendarNumber {
        case 1: return .monday
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        case 6: return .saturday
        case 7: return .sunday
        default: return nil
        }
    }

    static func from(date: Date) -> ProgramWeekday? {
        let weekday = AppCalendar.calendar.component(.weekday, from: date)
        let internalNumber = weekday == 1 ? 7 : weekday - 1
        return from(calendarNumber: internalNumber)
    }

    static func localizedTitle(for day: ProgramWeekday) -> String {
        switch day {
        case .monday: return String(localized: "weekday_monday")
        case .tuesday: return String(localized: "weekday_tuesday")
        case .wednesday: return String(localized: "weekday_wednesday")
        case .thursday: return String(localized: "weekday_thursday")
        case .friday: return String(localized: "weekday_friday")
        case .saturday: return String(localized: "weekday_saturday")
        case .sunday: return String(localized: "weekday_sunday")
        }
    }

    static func localizedShortTitle(for day: ProgramWeekday) -> String {
        switch day {
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
