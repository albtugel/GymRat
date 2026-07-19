import Foundation

@MainActor
protocol ScheduleServiceType {
    func fetchAssignments() async throws -> [ScheduleItem]
    func saveSchedule(_ assignments: [ScheduleItem]) async throws
    func saveChanges() async throws
}
