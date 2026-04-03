import Foundation

protocol CalendarServiceProtocol {
    func requestAccess() async throws -> Bool
    func fetchEvents(start: Date, end: Date) async throws -> [TimelineItem]
    func addEvent(item: TimelineItem) async throws
}
