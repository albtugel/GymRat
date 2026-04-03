import Foundation
import SwiftData

@MainActor
final class ProgramExerciseLogService: ProgramExerciseLogServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchLogs(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool) async throws -> [ProgramExerciseLog] {
        let predicate: Predicate<ProgramExerciseLog>
        if sharedHistory {
            predicate = #Predicate<ProgramExerciseLog> { log in
                log.programExercise.exercise.id == exerciseId
            }
        } else {
            predicate = #Predicate<ProgramExerciseLog> { log in
                log.programExercise.id == programExerciseId
            }
        }
        let descriptor = FetchDescriptor<ProgramExerciseLog>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }

    func fetchLog(programExerciseId: UUID, exerciseId: UUID, sharedHistory: Bool, dayStamp: Int) async throws -> ProgramExerciseLog? {
        let predicate: Predicate<ProgramExerciseLog>
        if sharedHistory {
            predicate = #Predicate<ProgramExerciseLog> { log in
                log.programExercise.exercise.id == exerciseId && log.dayStamp == dayStamp
            }
        } else {
            predicate = #Predicate<ProgramExerciseLog> { log in
                log.programExercise.id == programExerciseId && log.dayStamp == dayStamp
            }
        }
        let descriptor = FetchDescriptor<ProgramExerciseLog>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func insertLog(_ log: ProgramExerciseLog) async throws {
        modelContext.insert(log)
        try modelContext.save()
    }

    func deleteLog(_ log: ProgramExerciseLog) async throws {
        modelContext.delete(log)
        try modelContext.save()
    }

    func saveChanges() async throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
