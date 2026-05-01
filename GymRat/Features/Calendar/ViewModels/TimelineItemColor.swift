import Foundation

struct TimelineItemColor: Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double

    static let workout = TimelineItemColor(red: 0, green: 0, blue: 1, opacity: 1)
    static let personal = TimelineItemColor(red: 0, green: 1, blue: 0, opacity: 1)
    static let externalCalendar = TimelineItemColor(red: 1, green: 0.5, blue: 0, opacity: 1)
}
