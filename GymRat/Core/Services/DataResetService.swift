import Foundation
import SwiftData

/// Bulk-deletes user data on a model actor off the main thread, so the UI is not tied up while every row goes.
struct DataResetService: DataResetServiceType {
    private let storage: BackgroundModelActor<DataResetStorage>

    init(modelContainer: ModelContainer) {
        storage = BackgroundModelActor { DataResetStorage(modelContainer: modelContainer) }
    }

    func resetAllData() async throws {
        try await storage.get().resetAllData()
    }
}

@ModelActor
private actor DataResetStorage {
    func resetAllData() throws {
        try deleteAll(ExerciseLog.self)
        try deleteAll(ScheduleItem.self)
        try deleteAll(WorkoutExercise.self)
        try deleteAll(Program.self)

        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let items = try modelContext.fetch(FetchDescriptor<T>())
        items.forEach { modelContext.delete($0) }
    }
}
