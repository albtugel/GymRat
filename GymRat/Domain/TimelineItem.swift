import Foundation
import SwiftData

enum TimelineItemType: String, Codable {
    case workout, personal, externalCalendar
}

@Model
final class TimelineItem {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var startDate: Date
    var endDate: Date
    var typeRaw: String
    var program: ProgramModel?

    var type: TimelineItemType {
        get { TimelineItemType(rawValue: typeRaw) ?? .workout }
        set { typeRaw = newValue.rawValue }
    }

    init(title: String, startDate: Date, endDate: Date, type: TimelineItemType, program: ProgramModel? = nil) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.typeRaw = type.rawValue
        self.program = program
    }
}
