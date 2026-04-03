import Foundation

enum TimelineItemMapper {
    static func type(for item: TimelineItem) -> TimelineItemType {
        TimelineItemType(rawValue: item.typeRaw) ?? .workout
    }
}
