import Foundation
import SwiftData

@MainActor
final class ProgramAssignmentService: ProgramAssignmentServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAssignments() async throws -> [ProgramAssignment] {
        let descriptor = FetchDescriptor<ProgramAssignment>()
        return try modelContext.fetch(descriptor)
    }

    func insertAssignments(_ assignments: [ProgramAssignment]) async throws {
        assignments.forEach { modelContext.insert($0) }
        try modelContext.save()
    }

    func deleteAssignments(forProgramId programId: UUID) async throws {
        let descriptor = FetchDescriptor<ProgramAssignment>()
        let assignments = try modelContext.fetch(descriptor)
        for assignment in assignments where assignment.program.id == programId {
            modelContext.delete(assignment)
        }
        try modelContext.save()
    }

    func saveChanges() async throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
