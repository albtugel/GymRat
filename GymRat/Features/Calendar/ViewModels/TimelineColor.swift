import Foundation

struct TimelineColor: Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double

    static let workout = TimelineColor(red: 0, green: 0, blue: 1, opacity: 1)
    static let personal = TimelineColor(red: 0, green: 1, blue: 0, opacity: 1)
    static let externalCalendar = TimelineColor(red: 1, green: 0.5, blue: 0, opacity: 1)
}
