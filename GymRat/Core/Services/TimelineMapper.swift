import Foundation

enum TimelineMapper {
    static func type(for item: Event) -> EventType {
        EventType(rawValue: item.typeRaw) ?? .workout
    }
}
