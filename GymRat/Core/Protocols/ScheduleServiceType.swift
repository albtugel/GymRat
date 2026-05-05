import Foundation

@MainActor
protocol ScheduleServiceType {
    func fetchAssignments() async throws -> [ScheduleItem]
    func saveSchedule(_ assignments: [ScheduleItem]) async throws
    func deleteAssignments(forProgramId programId: UUID) async throws
    func saveChanges() async throws
}
