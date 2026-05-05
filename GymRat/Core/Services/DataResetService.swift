import Foundation
import SwiftData

@MainActor
final class DataResetService: DataResetServiceType {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func resetAllData() async throws {
        try deleteAll(ExerciseLog.self)
        try deleteAll(ScheduleItem.self)
        try deleteAll(DayProgram.self)
        try deleteAll(Event.self)
        try deleteAll(WorkoutExercise.self)
        try deleteAll(Program.self)

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
