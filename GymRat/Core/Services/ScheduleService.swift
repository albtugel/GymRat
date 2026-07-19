import Foundation
import SwiftData

@MainActor
final class ScheduleService: ScheduleServiceType {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAssignments() async throws -> [ScheduleItem] {
        let descriptor = FetchDescriptor<ScheduleItem>()
        let assignments = try modelContext.fetch(descriptor)
        return assignments.filter { $0.program != nil }
    }

    func saveSchedule(_ assignments: [ScheduleItem]) async throws {
        assignments.forEach { modelContext.insert($0) }
        try modelContext.save()
    }

    func saveChanges() async throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
