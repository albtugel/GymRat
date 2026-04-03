import Foundation

protocol ProgramAssignmentServiceProtocol {
    func fetchAssignments() async throws -> [ProgramAssignment]
    func insertAssignments(_ assignments: [ProgramAssignment]) async throws
    func deleteAssignments(forProgramId programId: UUID) async throws
    func saveChanges() async throws
}
