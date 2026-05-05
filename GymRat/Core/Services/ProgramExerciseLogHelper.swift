import Foundation

enum ExerciseLogHelper {
    static func startOfDay(for date: Date) -> Date {
        AppCalendar.calendar.startOfDay(for: date)
    }

    static func makeDayStamp(for date: Date) -> Int {
        let comps = AppCalendar.calendar.dateComponents([.year, .month, .day], from: date)
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        let day = comps.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}
