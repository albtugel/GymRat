import Foundation

@MainActor
protocol ScheduleServiceType {
    func fetchAssignments() throws -> [ScheduleItem]
    func saveSchedule(_ assignments: [ScheduleItem]) throws
    func saveChanges() throws
}
