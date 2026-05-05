import Foundation
import SwiftData

@MainActor
final class ExerciseLogService: ExerciseLogServiceType {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchLogs(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool) async throws -> [ExerciseLog] {
        let predicate: Predicate<ExerciseLog>
        if sharedHistory {
            predicate = #Predicate<ExerciseLog> { log in
                log.programExercise.exercise.id == exerciseId
            }
        } else {
            predicate = #Predicate<ExerciseLog> { log in
                log.programExercise.id == programExerciseId
            }
        }
        let descriptor = FetchDescriptor<ExerciseLog>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    func fetchLog(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool, dayStamp: Int) async throws -> ExerciseLog? {
        let predicate: Predicate<ExerciseLog>
        if sharedHistory {
            predicate = #Predicate<ExerciseLog> { log in
                log.programExercise.exercise.id == exerciseId && log.dayStamp == dayStamp
            }
        } else {
            predicate = #Predicate<ExerciseLog> { log in
                log.programExercise.id == programExerciseId && log.dayStamp == dayStamp
            }
        }
        let descriptor = FetchDescriptor<ExerciseLog>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func insertLog(_ log: ExerciseLog) async throws {
        modelContext.insert(log)
        try modelContext.save()
    }

    func deleteLog(_ log: ExerciseLog) async throws {
        modelContext.delete(log)
        try modelContext.save()
    }

    func saveChanges() async throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
