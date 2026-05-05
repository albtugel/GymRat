import Foundation

@MainActor
protocol CalendarServiceType {
    func requestAccess() async throws -> Bool
    func fetchEvents(start: Date, end: Date) async throws -> [Event]
    func addEvent(item: Event) async throws
}
