import Foundation
import Observation
import Kingfisher

/// App-wide list of the user's programs. Everything the UI shows comes from snapshots; writes go
/// through `ProgramStoreType` and the list is refreshed from the store afterwards.
@Observable
@MainActor
final class ProgramViewModel {
    private(set) var customPrograms: [ProgramSnapshot] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    private let exerciseService: any ExerciseServiceType
    private let programStore: any ProgramStoreType
    private let dataResetService: any DataResetServiceType

    init(
        exerciseService: any ExerciseServiceType,
        programStore: any ProgramStoreType,
        dataResetService: any DataResetServiceType
    ) {
        self.exerciseService = exerciseService
        self.programStore = programStore
        self.dataResetService = dataResetService
    }

    func programs(for date: Date) -> [ProgramSnapshot] {
        guard let weekday = ProgramWeekdayHelper.from(date: date) else { return [] }
        return customPrograms.filter { $0.weekdays.contains(weekday) }
    }

    var hasCustomPrograms: Bool {
        !customPrograms.isEmpty
    }

    func makeProgram(name: String, type: ProgramType) -> ProgramSnapshot {
        ProgramSnapshot(name: name, type: type)
    }

    func dismissError() {
        errorMessage = nil
    }

    func loadPrograms() async {
        isLoading = true
        defer { isLoading = false }
        do {
            customPrograms = try await programStore.fetchPrograms()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func seedExercisesIfNeeded() async {
        do {
            try await exerciseService.seedIfNeeded()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Persists a new or edited program and refreshes the list from the store, so changes the store
    /// made on the side (shared history in other programs) show up too.
    func saveProgram(_ program: ProgramSnapshot) async throws {
        _ = try await programStore.save(program)
        customPrograms = try await programStore.fetchPrograms()
    }

    func deleteProgram(id: UUID) async {
        customPrograms.removeAll { $0.id == id }
        do {
            try await programStore.deleteProgram(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePrograms(at offsets: IndexSet) async {
        let ids = offsets.compactMap { customPrograms.indices.contains($0) ? customPrograms[$0].id : nil }
        for id in ids {
            await deleteProgram(id: id)
        }
    }

    func reorderExercises(programID: UUID, orderedExerciseIDs: [UUID]) async {
        if let index = customPrograms.firstIndex(where: { $0.id == programID }) {
            let position = Dictionary(orderedExerciseIDs.enumerated().map { ($1, $0 + 1) }, uniquingKeysWith: { first, _ in first })
            customPrograms[index].exercises = customPrograms[index].exercises
                .map { exercise in
                    var exercise = exercise
                    if let newIndex = position[exercise.id] {
                        exercise.selectionIndex = newIndex
                    }
                    return exercise
                }
                .sorted { $0.selectionIndex < $1.selectionIndex }
        }
        do {
            try await programStore.reorderExercises(programID: programID, orderedExerciseIDs: orderedExerciseIDs)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetPrograms() {
        customPrograms = []
    }

    func resetAllData() async {
        do {
            try await dataResetService.resetAllData()

            ImageCache.default.clearMemoryCache()
            ImageCache.default.clearDiskCache {
                AppLog.imageCache.notice("Kingfisher cache cleared")
            }

            resetPrograms()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Session-only ordering of the day's cards; positions are not persisted.
    func reorderPrograms(_ reordered: [ProgramSnapshot]) {
        let ids = reordered.map(\.id)
        var updated = customPrograms
        let indices = updated.enumerated().compactMap { index, element in
            ids.contains(element.id) ? index : nil
        }
        if indices.count == reordered.count {
            for (orderIndex, programIndex) in indices.enumerated() {
                updated[programIndex] = reordered[orderIndex]
            }
            customPrograms = updated
        } else {
            updated.removeAll { ids.contains($0.id) }
            updated.append(contentsOf: reordered)
            customPrograms = updated
        }
    }
}
