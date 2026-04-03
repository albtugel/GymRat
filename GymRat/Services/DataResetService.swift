import Foundation
import SwiftData

@MainActor
final class DataResetService: DataResetServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func resetAllData() async throws {
        try deleteAll(ProgramExerciseLog.self)
        try deleteAll(ProgramAssignment.self)
        try deleteAll(DayProgramModel.self)
        try deleteAll(TimelineItem.self)
        try deleteAll(ProgramExercise.self)
        try deleteAll(ProgramModel.self)

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let items = try modelContext.fetch(descriptor)
        items.forEach { modelContext.delete($0) }
    }
}
