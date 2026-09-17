import Foundation
import SwiftData

/// SwiftData-backed `ProgramStoreType`. All graph work — reconciling a program's exercises, cascading
/// history, schedule entries — happens on a model actor off the main thread.
struct ProgramStore: ProgramStoreType {
    enum StoreError: Error {
        case missingProgram(UUID)
        case missingExercise(UUID)
    }

    private let storage: BackgroundModelActor<ProgramStorage>

    init(modelContainer: ModelContainer) {
        storage = BackgroundModelActor { ProgramStorage(modelContainer: modelContainer) }
    }

    func fetchPrograms() async throws -> [ProgramSnapshot] {
        try await storage.get().fetchPrograms()
    }

    func save(_ program: ProgramSnapshot) async throws -> ProgramSnapshot {
        try await storage.get().save(program)
    }

    func deleteProgram(id: UUID) async throws {
        try await storage.get().deleteProgram(id: id)
    }

    func reorderExercises(programID: UUID, orderedExerciseIDs: [UUID]) async throws {
        try await storage.get().reorderExercises(programID: programID, orderedExerciseIDs: orderedExerciseIDs)
    }

    func shareHistory(exerciseID: UUID) async throws {
        try await storage.get().shareHistory(exerciseID: exerciseID)
    }
}

@ModelActor
private actor ProgramStorage {
    func fetchPrograms() throws -> [ProgramSnapshot] {
        let programs = try modelContext.fetch(FetchDescriptor<Program>())
        if assignMissingPositions(in: programs) {
            try modelContext.save()
        }
        return programs.map(Self.snapshot)
    }

    func save(_ snapshot: ProgramSnapshot) throws -> ProgramSnapshot {
        let program: Program
        let isNew: Bool
        if let existing = try fetchProgram(id: snapshot.id) {
            program = existing
            isNew = false
        } else {
            program = Program(id: snapshot.id, name: snapshot.name, typeRaw: snapshot.type.rawValue)
            modelContext.insert(program)
            isNew = true
        }
        program.name = snapshot.name
        program.typeRaw = snapshot.type.rawValue
        program.colorHex = snapshot.colorHex
        program.weekdaysRaw = snapshot.weekdays.map(\.rawValue)
        try reconcileExercises(of: program, with: snapshot.exercises)
        if isNew {
            insertSchedule(for: program, weekdays: snapshot.weekdays)
        }
        try modelContext.save()
        return Self.snapshot(program)
    }

    func deleteProgram(id: UUID) throws {
        guard let program = try fetchProgram(id: id) else { return }
        let workouts = program.exercises
        let departingIDs = Set(workouts.map(\.id))
        for workout in workouts {
            try retire(workout, alongWith: departingIDs)
        }
        // Program.scheduleItems cascade.
        modelContext.delete(program)
        try modelContext.save()
    }

    func reorderExercises(programID: UUID, orderedExerciseIDs: [UUID]) throws {
        guard let program = try fetchProgram(id: programID) else {
            throw ProgramStore.StoreError.missingProgram(programID)
        }
        let byID = Dictionary(program.exercises.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for (index, id) in orderedExerciseIDs.enumerated() {
            guard let workout = byID[id] else { continue }
            if workout.selectionIndex != index + 1 {
                workout.selectionIndex = index + 1
            }
        }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    func shareHistory(exerciseID: UUID) throws {
        let workouts = try modelContext.fetch(
            FetchDescriptor<WorkoutExercise>(predicate: #Predicate { $0.exercise.id == exerciseID })
        )
        for workout in workouts where !workout.sharedHistory {
            workout.sharedHistory = true
        }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    // MARK: - Reconciliation

    /// Brings `program.exercises` in line with the snapshot: new exercises are created, kept ones are
    /// updated in place, and removed ones are retired once the new list is in place (so a shared
    /// history can move to an exercise added in the same save).
    private func reconcileExercises(of program: Program, with snapshots: [WorkoutExerciseSnapshot]) throws {
        let wantedIDs = Set(snapshots.map(\.id))
        let removed = program.exercises.filter { !wantedIDs.contains($0.id) }
        var byID = Dictionary(
            program.exercises.filter { wantedIDs.contains($0.id) }.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        var ordered: [WorkoutExercise] = []
        for (index, item) in snapshots.enumerated() {
            let workout: WorkoutExercise
            if let existing = byID[item.id] {
                workout = existing
                if workout.exercise.id != item.exercise.id {
                    workout.exercise = try requireExercise(id: item.exercise.id)
                }
            } else {
                workout = WorkoutExercise(
                    id: item.id,
                    exercise: try requireExercise(id: item.exercise.id),
                    sets: item.sets,
                    reps: item.reps,
                    selectionIndex: item.selectionIndex,
                    sharedHistory: item.sharedHistory
                )
                modelContext.insert(workout)
                byID[item.id] = workout
            }
            workout.sets = item.sets
            workout.reps = item.reps
            workout.sharedHistory = item.sharedHistory
            workout.selectionIndex = item.selectionIndex > 0 ? item.selectionIndex : index + 1
            ordered.append(workout)
        }
        program.exercises = ordered

        let departingIDs = Set(removed.map(\.id))
        for workout in removed {
            try retire(workout, alongWith: departingIDs)
        }
    }

    /// Programs saved by early releases left `selectionIndex` at 0; give those a stable position.
    private func assignMissingPositions(in programs: [Program]) -> Bool {
        var didChange = false
        for program in programs {
            var next = program.exercises.map(\.selectionIndex).max() ?? 0
            for workout in program.exercises where workout.selectionIndex == 0 {
                next += 1
                workout.selectionIndex = next
                didChange = true
            }
        }
        return didChange
    }

    /// One schedule entry per selected weekday of the current week.
    private func insertSchedule(for program: Program, weekdays: Set<ProgramWeekday>) {
        let calendar = AppCalendar.calendar
        let startOfWeek = Date().startOfWeek
        for weekday in weekdays {
            let components = DateComponents(weekday: ProgramWeekdayHelper.systemWeekdayNumber(for: weekday))
            guard let date = calendar.nextDate(
                after: startOfWeek.addingTimeInterval(-1),
                matching: components,
                matchingPolicy: .nextTime
            ) else { continue }
            modelContext.insert(ScheduleItem(program: program, date: date))
        }
    }

    /// Deletes a program exercise without losing history other programs still show.
    ///
    /// A row with shared history reads every log of its exercise, whichever program exercise wrote
    /// it. So while some other program exercise of the same exercise keeps sharing history, the
    /// departing one's logs move to it and stay visible there. Otherwise nothing could reach those
    /// logs any more, and they are deleted with it.
    ///
    /// - Parameter departingIDs: program exercises leaving in the same operation; never heirs.
    private func retire(_ workout: WorkoutExercise, alongWith departingIDs: Set<UUID>) throws {
        let workoutID = workout.id
        let exerciseID = workout.exercise.id
        let logs = try modelContext.fetch(
            FetchDescriptor<ExerciseLog>(predicate: #Predicate { $0.programExercise.id == workoutID })
        )
        // Filtered in memory: sharedHistory may have changed earlier in this save.
        let heir = try modelContext
            .fetch(FetchDescriptor<WorkoutExercise>(predicate: #Predicate { $0.exercise.id == exerciseID }))
            .first { $0.sharedHistory && !departingIDs.contains($0.id) }

        if let heir {
            logs.forEach { $0.programExercise = heir }
        } else {
            logs.forEach { modelContext.delete($0) }
        }
        modelContext.delete(workout)
    }

    private func fetchProgram(id: UUID) throws -> Program? {
        try modelContext.fetch(FetchDescriptor<Program>(predicate: #Predicate { $0.id == id })).first
    }

    private func requireExercise(id: UUID) throws -> Exercise {
        guard let exercise = try modelContext
            .fetch(FetchDescriptor<Exercise>(predicate: #Predicate { $0.id == id }))
            .first
        else {
            throw ProgramStore.StoreError.missingExercise(id)
        }
        return exercise
    }

    // MARK: - Snapshots

    private static func snapshot(_ program: Program) -> ProgramSnapshot {
        ProgramSnapshot(
            id: program.id,
            name: program.name,
            type: ProgramType(rawValue: program.typeRaw) ?? .strength,
            colorHex: program.colorHex,
            weekdays: Set(program.weekdaysRaw.compactMap(ProgramWeekday.init(rawValue:))),
            exercises: program.exercises
                .sorted { $0.selectionIndex < $1.selectionIndex }
                .map(snapshot)
        )
    }

    private static func snapshot(_ workout: WorkoutExercise) -> WorkoutExerciseSnapshot {
        WorkoutExerciseSnapshot(
            id: workout.id,
            exercise: ExerciseSnapshot(
                id: workout.exercise.id,
                name: workout.exercise.name,
                category: ExerciseCategory(rawValue: workout.exercise.categoryRaw) ?? .strength,
                isCustom: workout.exercise.isCustom
            ),
            sets: workout.sets,
            reps: workout.reps,
            selectionIndex: workout.selectionIndex,
            sharedHistory: workout.sharedHistory
        )
    }
}
