import Foundation
import Observation

/// The exercise list of the program editor: catalog + custom exercises, search and muscle filters,
/// the selection itself, custom-exercise creation and the shared-history choice.
@Observable
@MainActor
final class ExercisePickerViewModel {
    let programID: UUID
    let programType: ProgramType
    let isEditing: Bool

    private(set) var selectedExercises: [WorkoutExerciseSnapshot]
    private(set) var customExercises: [ExerciseSnapshot] = []
    private(set) var exerciseSeeds: [ExerciseRepo.ExerciseSeed] = []
    private(set) var searchText: String = ""
    private(set) var selectedMuscles: Set<MuscleGroup> = []
    private(set) var showCreateAlert: Bool = false
    private(set) var newExerciseName: String = ""
    private(set) var newExerciseCategory: ExerciseCategory = .strength
    private(set) var showSharedHistoryAlert: Bool = false
    private(set) var pendingSeed: ExerciseRepo.ExerciseSeed?
    private(set) var errorMessage: String?
    /// Programs other than the one being edited; used to offer shared history.
    private var otherPrograms: [ProgramSnapshot] = []

    private let exerciseService: any ExerciseServiceType
    private let programStore: any ProgramStoreType
    private let logStore: any ExerciseLogStoreType
    private let exerciseStore: any ExerciseStoreType

    init(
        programID: UUID,
        programType: ProgramType,
        isEditing: Bool,
        selectedExercises: [WorkoutExerciseSnapshot],
        exerciseService: any ExerciseServiceType,
        programStore: any ProgramStoreType,
        logStore: any ExerciseLogStoreType,
        exerciseStore: any ExerciseStoreType
    ) {
        self.programID = programID
        self.programType = programType
        self.isEditing = isEditing
        self.selectedExercises = selectedExercises
        self.exerciseService = exerciseService
        self.programStore = programStore
        self.logStore = logStore
        self.exerciseStore = exerciseStore
    }

    // MARK: - Derived state

    var showsMuscleFilter: Bool {
        switch programType {
        case .strength, .crossfit:
            return true
        case .cardio:
            return false
        }
    }

    var filteredExerciseSeeds: [ExerciseRepo.ExerciseSeed] {
        var seeds = exerciseSeeds
            .filter { ProgramTypeText.allows(programType, category: $0.category) }

        let custom = customExercises
            .filter { $0.isCustom && ProgramTypeText.allows(programType, category: $0.category) }
            .map {
                ExerciseRepo.ExerciseSeed(
                    name: $0.name,
                    category: $0.category,
                    muscles: [],
                    inputType: $0.category == .cardio ? .cardioDistance : .strength,
                    exerciseId: nil,
                    remoteExercise: nil
                )
            }
        seeds.append(contentsOf: custom)

        if showsMuscleFilter, !selectedMuscles.isEmpty {
            seeds = seeds.filter { !selectedMuscles.isDisjoint(with: $0.muscles) }
        }

        if !searchText.isEmpty {
            let query = searchText.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            seeds = seeds.filter {
                $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current).contains(query)
            }
        }
        return seeds
    }

    var selectedExerciseIds: [UUID] {
        selectedExercises.map(\.id)
    }

    var aiAvailableExerciseNames: [String] {
        let seedNames = exerciseSeeds.flatMap { [$0.name, $0.canonicalName] }
        let customNames = customExercises.map(\.name)
        return Array(Set(seedNames + customNames)).sorted()
    }

    func resolveSelectionInfo(for seed: ExerciseRepo.ExerciseSeed) -> SelectionInfo {
        guard let index = selectedExercises.firstIndex(where: { $0.exercise.name == seed.name }) else {
            return SelectionInfo(selectedExercise: nil, selectionNumber: nil)
        }
        return SelectionInfo(selectedExercise: selectedExercises[index], selectionNumber: isEditing ? nil : index + 1)
    }

    func isMuscleSelected(_ muscle: MuscleGroup) -> Bool {
        selectedMuscles.contains(muscle)
    }

    // MARK: - Loading

    func seedExercisesIfNeeded() async {
        await ExerciseSeeder.seedIfNeeded(using: exerciseService)
    }

    func load() async {
        exerciseSeeds = await exerciseStore.seedSnapshot()
        refreshExerciseCatalogInBackground()
        await reloadCustomExercises()
        do {
            otherPrograms = try await programStore.fetchPrograms().filter { $0.id != programID }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshExerciseCatalogInBackground() {
        Task { [exerciseStore] in
            await exerciseStore.refresh()
            let refreshedSeeds = await exerciseStore.seedSnapshot()
            await MainActor.run {
                self.exerciseSeeds = refreshedSeeds
            }
        }
    }

    private func reloadCustomExercises() async {
        do {
            customExercises = try await exerciseService.fetchExercises().filter(\.isCustom)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search and filters

    func updateSearch(_ text: String) {
        searchText = text
    }

    func clearSearchText() {
        searchText = ""
    }

    func toggleMuscle(_ muscle: MuscleGroup) {
        if selectedMuscles.contains(muscle) {
            selectedMuscles.remove(muscle)
        } else {
            selectedMuscles.insert(muscle)
        }
    }

    // MARK: - Custom exercises

    func updateNewExerciseName(_ name: String) {
        newExerciseName = name
    }

    func updateNewExerciseCategory(_ category: ExerciseCategory) {
        newExerciseCategory = category
    }

    func presentCreateExerciseAlert() {
        showCreateAlert = true
    }

    func dismissCreateExerciseAlert() {
        showCreateAlert = false
        newExerciseName = ""
    }

    func createCustomExercise() async {
        let trimmed = newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            try await exerciseService.addExercise(ExerciseSnapshot(name: trimmed, category: newExerciseCategory, isCustom: true))
            await reloadCustomExercises()
            newExerciseName = ""
            showCreateAlert = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Selection

    func toggleExercise(_ seed: ExerciseRepo.ExerciseSeed) async {
        if let index = selectedExercises.firstIndex(where: { $0.exercise.name == seed.name }) {
            selectedExercises.remove(at: index)
            return
        }
        guard let exercise = await fetchOrCreateExercise(seed) else { return }
        let existsInOtherPrograms = otherPrograms
            .flatMap(\.exercises)
            .contains { $0.exercise.id == exercise.id }
        if existsInOtherPrograms {
            pendingSeed = seed
            showSharedHistoryAlert = true
        } else {
            selectedExercises.append(WorkoutExerciseSnapshot(exercise: exercise, sharedHistory: false))
        }
    }

    func addPendingExercise(sharedHistory: Bool) async {
        guard let seed = pendingSeed else { return }
        guard let exercise = await fetchOrCreateExercise(seed) else { return }
        defer { clearPendingSelection() }
        guard !selectedExercises.contains(where: { $0.exercise.id == exercise.id }) else { return }
        selectedExercises.append(WorkoutExerciseSnapshot(exercise: exercise, sharedHistory: sharedHistory))
        guard sharedHistory else { return }
        do {
            try await programStore.shareHistory(exerciseID: exercise.id)
            otherPrograms = try await programStore.fetchPrograms().filter { $0.id != programID }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissSharedHistoryAlert() {
        clearPendingSelection()
    }

    func replaceSelection(with exercises: [WorkoutExerciseSnapshot]) {
        selectedExercises = exercises
    }

    func clearHistory(for exercise: WorkoutExerciseSnapshot) async {
        let scope = ExerciseLogScope(
            programExerciseID: exercise.id,
            exerciseID: exercise.exercise.id,
            sharedHistory: exercise.sharedHistory
        )
        do {
            try await logStore.deleteLogs(in: scope)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    // MARK: - AI plan editing

    func makeAIPlanPreview(from response: AIPlanEditResponse) async throws -> AIPlanEditPreview {
        try AIPlanEditApplier.makePreview(
            response: response,
            availableExercises: try await availableExercisesForAI(),
            seedNames: aiAvailableExerciseNames,
            existingSelectedExercises: selectedExercises
        )
    }

    /// Applies the preview to the selection, storing any custom exercises it introduces.
    /// Returns the program name the plan suggested, if any.
    func applyAIPlanPreview(_ preview: AIPlanEditPreview) async -> String? {
        do {
            let result = AIPlanEditApplier.apply(
                preview: preview,
                programType: programType,
                existingSelectedExercises: selectedExercises,
                availableExercises: try await availableExercisesForAI()
            )
            for exercise in result.customExercises {
                try await exerciseService.addExercise(exercise)
            }
            for workout in result.exercises where try await exerciseService.fetchExercise(named: workout.exercise.name) == nil {
                try await exerciseService.addExercise(workout.exercise)
            }
            selectedExercises = result.exercises
            await reloadCustomExercises()
            errorMessage = nil
            return result.programName
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Helpers

    private func fetchOrCreateExercise(_ seed: ExerciseRepo.ExerciseSeed) async -> ExerciseSnapshot? {
        do {
            if let existing = try await exerciseService.fetchExercise(named: seed.name) {
                return existing
            }
            let exercise = ExerciseSnapshot(name: seed.name, category: seed.category)
            try await exerciseService.addExercise(exercise)
            await reloadCustomExercises()
            return exercise
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func availableExercisesForAI() async throws -> [ExerciseSnapshot] {
        var exercises = try await exerciseService.fetchExercises()
        let existingNames = Set(exercises.map { normalizedExerciseName($0.name) })
        let seedExercises = exerciseSeeds
            .filter { !existingNames.contains(normalizedExerciseName($0.name)) }
            .map { ExerciseSnapshot(name: $0.name, category: $0.category) }
        exercises.append(contentsOf: seedExercises)
        return exercises
    }

    private func normalizedExerciseName(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }

    private func clearPendingSelection() {
        pendingSeed = nil
        showSharedHistoryAlert = false
    }
}
