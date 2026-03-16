import Foundation
import SwiftData

enum TimelineItemType: String, Codable {
    case workout, personal, externalCalendar
}

@Model
final class TimelineItem {
    var title: String
    var startDate: Date
    var endDate: Date
    var type: TimelineItemType
    var workoutSession: WorkoutSession?

    init(title: String, startDate: Date, endDate: Date, type: TimelineItemType, workoutSession: WorkoutSession? = nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.workoutSession = workoutSession
    }
}
