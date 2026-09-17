import Foundation
import SwiftData

/// SwiftData-backed `ExerciseLogStoreType`. The work runs on a model actor with its own `ModelContext`
/// off the main thread, so history fetches and set saves never block the UI; callers only see snapshots.
struct ExerciseLogStore: ExerciseLogStoreType {
    enum StoreError: Error {
        case missingProgramExercise(UUID)
    }

    private let storage: BackgroundModelActor<ExerciseLogStorage>

    init(modelContainer: ModelContainer) {
        storage = BackgroundModelActor { ExerciseLogStorage(modelContainer: modelContainer) }
    }

    func fetchLogs(in scope: ExerciseLogScope) async throws -> [ExerciseLogSnapshot] {
        try await storage.get().fetchLogs(in: scope)
    }

    func saveLog(
        in scope: ExerciseLogScope,
        day: Date,
        sets: Int?,
        values: ExerciseLogValues,
        keepEmpty: Bool
    ) async throws -> ExerciseLogSnapshot? {
        try await storage.get().saveLog(in: scope, day: day, sets: sets, values: values, keepEmpty: keepEmpty)
    }

    func deleteLogs(in scope: ExerciseLogScope) async throws {
        try await storage.get().deleteLogs(in: scope)
    }
}

@ModelActor
private actor ExerciseLogStorage {
    func fetchLogs(in scope: ExerciseLogScope) throws -> [ExerciseLogSnapshot] {
        let logs = try modelContext.fetch(FetchDescriptor<ExerciseLog>(predicate: Self.predicate(for: scope)))
        var didChange = normalizeDates(of: logs)
        let kept = collapseDuplicateDays(in: logs, didChange: &didChange)
        if didChange {
            try modelContext.save()
        }
        return kept.map(Self.snapshot).sorted { $0.dayStamp < $1.dayStamp }
    }

    func saveLog(
        in scope: ExerciseLogScope,
        day: Date,
        sets: Int?,
        values: ExerciseLogValues,
        keepEmpty: Bool
    ) throws -> ExerciseLogSnapshot? {
        let day = ExerciseLogHelper.startOfDay(for: day)
        let dayStamp = ExerciseLogHelper.makeDayStamp(for: day)
        guard let programExercise = try fetchProgramExercise(id: scope.programExerciseID) else {
            throw ExerciseLogStore.StoreError.missingProgramExercise(scope.programExerciseID)
        }
        if let sets, programExercise.sets != sets {
            programExercise.sets = sets
        }

        let existing = try modelContext
            .fetch(FetchDescriptor<ExerciseLog>(predicate: Self.predicate(for: scope, dayStamp: dayStamp)))
            .first
        let stored: ExerciseLog?
        if values.hasValues || keepEmpty {
            let log = existing ?? ExerciseLog(
                programExercise: programExercise,
                exerciseName: programExercise.exercise.name,
                date: day,
                dayStamp: dayStamp,
                repsBySet: [],
                weightsBySet: []
            )
            if existing == nil {
                modelContext.insert(log)
            }
            log.date = day
            log.dayStamp = dayStamp
            log.programExercise = programExercise
            log.exerciseName = programExercise.exercise.name
            log.repsBySet = values.repsBySet
            log.weightsBySet = values.weightsBySet
            log.durationsBySet = values.durationsBySet
            stored = log
        } else {
            if let existing {
                modelContext.delete(existing)
            }
            stored = nil
        }

        if modelContext.hasChanges {
            try modelContext.save()
        }
        return stored.map(Self.snapshot)
    }

    func deleteLogs(in scope: ExerciseLogScope) throws {
        let logs = try modelContext.fetch(FetchDescriptor<ExerciseLog>(predicate: Self.predicate(for: scope)))
        logs.forEach { modelContext.delete($0) }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    private func fetchProgramExercise(id: UUID) throws -> WorkoutExercise? {
        try modelContext.fetch(FetchDescriptor<WorkoutExercise>(predicate: #Predicate { $0.id == id })).first
    }

    /// Older releases stored the exact time of the entry; history is per day, so bring such rows in line.
    private func normalizeDates(of logs: [ExerciseLog]) -> Bool {
        var didChange = false
        for log in logs {
            let normalized = ExerciseLogHelper.startOfDay(for: log.date)
            let stamp = ExerciseLogHelper.makeDayStamp(for: normalized)
            if log.date != normalized {
                log.date = normalized
                didChange = true
            }
            if log.dayStamp != stamp {
                log.dayStamp = stamp
                didChange = true
            }
        }
        return didChange
    }

    /// Keeps the most complete log of each day and deletes the rest.
    private func collapseDuplicateDays(in logs: [ExerciseLog], didChange: inout Bool) -> [ExerciseLog] {
        var kept: [Int: ExerciseLog] = [:]
        for log in logs {
            guard let current = kept[log.dayStamp] else {
                kept[log.dayStamp] = log
                continue
            }
            let winner = Self.score(log) > Self.score(current) ? log : current
            let loser = winner === log ? current : log
            kept[log.dayStamp] = winner
            modelContext.delete(loser)
            didChange = true
        }
        return Array(kept.values)
    }

    private static func score(_ log: ExerciseLog) -> Int {
        log.repsBySet.filter { $0 > 0 }.count
            + log.weightsBySet.filter { $0 > 0 }.count
            + log.durationsBySet.filter { $0 > 0 }.count
    }

    private static func snapshot(_ log: ExerciseLog) -> ExerciseLogSnapshot {
        ExerciseLogSnapshot(
            id: log.id,
            dayStamp: log.dayStamp,
            values: ExerciseLogValues(
                repsBySet: log.repsBySet,
                weightsBySet: log.weightsBySet,
                durationsBySet: log.durationsBySet
            )
        )
    }

    private static func predicate(for scope: ExerciseLogScope, dayStamp: Int? = nil) -> Predicate<ExerciseLog> {
        let programExerciseID = scope.programExerciseID
        let exerciseID = scope.exerciseID
        switch (scope.sharedHistory, dayStamp) {
        case (true, nil):
            return #Predicate { $0.programExercise.exercise.id == exerciseID }
        case (true, let stamp?):
            return #Predicate { $0.programExercise.exercise.id == exerciseID && $0.dayStamp == stamp }
        case (false, nil):
            return #Predicate { $0.programExercise.id == programExerciseID }
        case (false, let stamp?):
            return #Predicate { $0.programExercise.id == programExerciseID && $0.dayStamp == stamp }
        }
    }
}
