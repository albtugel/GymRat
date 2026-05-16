import Foundation
import Observation

@Observable
@MainActor
final class ProgramEditorViewModel {


    private(set) var mode: ProgramEditorMode
    private(set) var program: Program
    private(set) var programName: String
    private(set) var programColorHex: String
    private(set) var selectedExercises: [WorkoutExercise]
    private(set) var selectedWeekdays: Set<ProgramWeekday>
    private(set) var customExercises: [Exercise] = []
    private(set) var allPrograms: [Program] = []
    private(set) var searchText: String = ""
    private(set) var selectedMuscles: Set<MuscleGroup> = []
    private(set) var showCreateAlert: Bool = false
    private(set) var newExerciseName: String = ""
    private(set) var newExerciseCategory: ExerciseCategory = .strength
    private(set) var isSaving: Bool = false
    private(set) var showSharedHistoryAlert: Bool = false
    private(set) var showNoSharedExerciseAlert: Bool = false
    private(set) var showWeekdaysRequiredAlert: Bool = false
    private(set) var pendingSeed: ExerciseRepo.ExerciseSeed?
    private(set) var exerciseSeeds: [ExerciseRepo.ExerciseSeed] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    private(set) var didSave: Bool = false
    private var didClearNameOnFocus: Bool = false


    private let programService: ProgramServiceType
    private let exerciseService: ExerciseServiceType
    private let exerciseLogService: ExerciseLogServiceType
    private let exerciseStore: ExerciseRepo
    private let programViewModel: ProgramViewModel

    init(
        mode: ProgramEditorMode,
        program: Program,
        programService: ProgramServiceType,
        exerciseService: ExerciseServiceType,
        exerciseLogService: ExerciseLogServiceType,
        exerciseStore: ExerciseRepo,
        programViewModel: ProgramViewModel
    ) {
        self.mode = mode
        self.program = program
        self.programName = program.name
        self.programColorHex = program.colorHex ?? ""
        self.selectedExercises = program.exercises
        self.selectedWeekdays = ProgramMapper.weekdays(for: program)
        self.programService = programService
        self.exerciseService = exerciseService
        self.exerciseLogService = exerciseLogService
        self.exerciseStore = exerciseStore
        self.programViewModel = programViewModel
    }


    var programType: ProgramType {
        ProgramMapper.type(for: program)
    }

    var programTitle: String {
        ProgramTypeText.title(for: programType)
    }

    var isEditing: Bool {
        mode == .edit
    }

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
            .filter { $0.isCustom && ProgramTypeText.allows(programType, category: ExerciseMapper.category(for: $0)) }
            .map {
                let category = ExerciseMapper.category(for: $0)
                let inputType: ExerciseInputType = category == .cardio ? .cardioDistance : .strength
                return ExerciseRepo.ExerciseSeed(
                    name: $0.name,
                    category: category,
                    muscles: [],
                    inputType: inputType,
                    exerciseId: nil,
                    remoteExercise: nil
                )
            }

        seeds.append(contentsOf: custom)

        if showsMuscleFilter, !selectedMuscles.isEmpty {
            seeds = seeds.filter { seed in
                !selectedMuscles.isDisjoint(with: seed.muscles)
            }
        }

        if !searchText.isEmpty {
            let query = searchText.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            seeds = seeds.filter {
                let name = $0.name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                return name.contains(query)
            }
        }

        return seeds
    }

    var selectedExerciseIds: [UUID] {
        selectedExercises.map(\.id)
    }

    var aiAvailableExerciseNames: [String] {
        let seedNames = exerciseSeeds.flatMap { seed in
            [seed.name, seed.canonicalName]
        }
        let customNames = customExercises.map(\.name)
        return Array(Set(seedNames + customNames)).sorted()
    }


    func updateProgramName(_ name: String) {
        programName = name
    }

    func updateProgramColorHex(_ hex: String) {
        programColorHex = hex
    }

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

    func toggleWeekday(_ day: ProgramWeekday) {
        if selectedWeekdays.contains(day) {
            selectedWeekdays.remove(day)
        } else {
            selectedWeekdays.insert(day)
        }
    }

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

    func dismissError() {
        errorMessage = nil
    }

    func dismissNoSharedExerciseAlert() {
        showNoSharedExerciseAlert = false
    }

    func dismissWeekdaysRequiredAlert() {
        showWeekdaysRequiredAlert = false
    }

    func handleNameFieldFocusChange(_ isFocused: Bool) {
        if isFocused && !didClearNameOnFocus {
            programName = ""
            didClearNameOnFocus = true
        }
    }

    func dismissSharedHistoryAlert() {
        showSharedHistoryAlert = false
        pendingSeed = nil
    }

    func isMuscleSelected(_ muscle: MuscleGroup) -> Bool {
        selectedMuscles.contains(muscle)
    }

    func isWeekdaySelected(_ day: ProgramWeekday) -> Bool {
        selectedWeekdays.contains(day)
    }

    func resolveSelectionInfo(for seed: ExerciseRepo.ExerciseSeed) -> SelectionInfo {
        guard let index = selectedExercises.firstIndex(where: { $0.exercise.name == seed.name }) else {
            return SelectionInfo(selectedExercise: nil, selectionNumber: nil)
        }
        let number = isEditing ? nil : index + 1
        return SelectionInfo(selectedExercise: selectedExercises[index], selectionNumber: number)
    }

    func seedExercisesIfNeeded() async {
        await ExerciseSeeder.seedIfNeeded(using: exerciseService)
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        exerciseSeeds = await exerciseStore.seedSnapshot()
        refreshExerciseCatalogInBackground()

        do {
            let exercises = try await exerciseService.fetchExercises()
            customExercises = exercises.filter { $0.isCustom }
        } catch {
            errorMessage = error.localizedDescription
        }

        do {
            allPrograms = try await programService.fetchPrograms()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func refreshExerciseCatalogInBackground() {
        Task { [exerciseStore] in
            _ = await exerciseStore.refresh()
            let refreshedSeeds = await exerciseStore.seedSnapshot()
            await MainActor.run {
                self.exerciseSeeds = refreshedSeeds
            }
        }
    }

    func toggleExercise(_ seed: ExerciseRepo.ExerciseSeed) async {
        if let index = selectedExercises.firstIndex(where: { $0.exercise.name == seed.name }) {
            selectedExercises.remove(at: index)
            return
        }

        guard let exercise = await fetchOrCreateExercise(seed) else { return }
        let existsInOtherPrograms = allPrograms
            .filter { $0.id != program.id }
            .flatMap { $0.exercises }
            .contains { $0.exercise.id == exercise.id }

        if existsInOtherPrograms {
            pendingSeed = seed
            showSharedHistoryAlert = true
        } else {
            selectedExercises.append(WorkoutExercise(exercise: exercise, sharedHistory: false))
        }
    }

    func addPendingExercise(sharedHistory: Bool) async {
        guard let seed = pendingSeed else { return }
        await addExercise(from: seed, sharedHistory: sharedHistory)
    }

    func createCustomExercise() async {
        let trimmed = newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }
        let newExercise = Exercise(name: trimmed, categoryRaw: newExerciseCategory.rawValue, isCustom: true)
        do {
            try await exerciseService.addExercise(newExercise)
            customExercises = (try await exerciseService.fetchExercises()).filter { $0.isCustom }
            newExerciseName = ""
            showCreateAlert = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save() async {
        guard canStartSave() else { return }
        isSaving = true
        defer { isSaving = false }

        updateProgramDetails()
        updateWorkoutExercises()
        ProgramMapper.setWeekdays(selectedWeekdays, for: program)

        guard await persistProgram() else { return }
        await finishSave()
    }

    func clearHistory(for exercise: WorkoutExercise) async {
        do {
            let logs = try await exerciseLogService.fetchLogs(
                programExerciseId: exercise.id,
                exerciseId: exercise.exercise.id,
                sharedHistory: exercise.sharedHistory
            )
            for log in logs {
                try await exerciseLogService.deleteLog(log)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func makeAIPlanPreview(from response: AIPlanEditResponse) async throws -> AIPlanEditPreview {
        let seedNames = aiAvailableExerciseNames
        let availableExercises = try await availableExercisesForAI()
        return try AIPlanEditApplier.makePreview(
            response: response,
            availableExercises: availableExercises,
            seedNames: seedNames,
            existingSelectedExercises: selectedExercises
        )
    }

    func applyAIPlanPreview(_ preview: AIPlanEditPreview) async {
        do {
            let availableExercises = try await availableExercisesForAI()
            let result = AIPlanEditApplier.apply(
                preview: preview,
                programType: programType,
                existingSelectedExercises: selectedExercises,
                availableExercises: availableExercises
            )
            for exercise in result.customExercises {
                try await exerciseService.addExercise(exercise)
            }
            for workoutExercise in result.exercises where try await exerciseService.fetchExercise(named: workoutExercise.exercise.name) == nil {
                try await exerciseService.addExercise(workoutExercise.exercise)
            }
            if let programName = result.programName {
                updateProgramName(programName)
            }
            selectedExercises = result.exercises
            customExercises = (try await exerciseService.fetchExercises()).filter { $0.isCustom }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }


    private func fetchOrCreateExercise(_ seed: ExerciseRepo.ExerciseSeed) async -> Exercise? {
        do {
            if let existing = try await exerciseService.fetchExercise(named: seed.name) {
                return existing
            }
            let newExercise = Exercise(name: seed.name, categoryRaw: seed.category.rawValue)
            try await exerciseService.addExercise(newExercise)
            customExercises = (try await exerciseService.fetchExercises()).filter { $0.isCustom }
            return newExercise
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func availableExercisesForAI() async throws -> [Exercise] {
        var exercises = try await exerciseService.fetchExercises()
        let existingNames = Set(exercises.map { normalizedExerciseName($0.name) })
        let seedExercises = exerciseSeeds
            .filter { !existingNames.contains(normalizedExerciseName($0.name)) }
            .map { Exercise(name: $0.name, categoryRaw: $0.category.rawValue) }
        exercises.append(contentsOf: seedExercises)
        return exercises
    }

    private func normalizedExerciseName(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }


    private func addExercise(from seed: ExerciseRepo.ExerciseSeed, sharedHistory: Bool) async {
        guard let exercise = await fetchOrCreateExercise(seed) else { return }
        guard !isExerciseSelected(exercise) else {
            clearPendingSelection()
            return
        }
        appendSelectedExercise(exercise, sharedHistory: sharedHistory)
        await updateSharedHistoryIfNeeded(sharedHistory, exercise: exercise)
        clearPendingSelection()
    }

    private func isExerciseSelected(_ exercise: Exercise) -> Bool {
        selectedExercises.contains(where: { $0.exercise.id == exercise.id })
    }

    private func appendSelectedExercise(_ exercise: Exercise, sharedHistory: Bool) {
        selectedExercises.append(WorkoutExercise(exercise: exercise, sharedHistory: sharedHistory))
    }

    private func updateSharedHistoryIfNeeded(_ sharedHistory: Bool, exercise: Exercise) async {
        guard sharedHistory else { return }
        applySharedHistory(for: exercise)
        await saveProgramSilently()
    }

    private func applySharedHistory(for exercise: Exercise) {
        allPrograms
            .filter { $0.id != program.id }
            .flatMap { $0.exercises }
            .filter { $0.exercise.id == exercise.id }
            .forEach { $0.sharedHistory = true }
    }

    private func saveProgramSilently() async {
        do {
            try await programService.save(program)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clearPendingSelection() {
        pendingSeed = nil
        showSharedHistoryAlert = false
    }

    private func canStartSave() -> Bool {
        if mode == .create && selectedWeekdays.isEmpty {
            showWeekdaysRequiredAlert = true
            return false
        }
        return !isSaving
    }

    private func updateProgramDetails() {
        program.name = programName.isEmpty ? programTitle : programName
        program.colorHex = programColorHex.isEmpty ? nil : programColorHex
    }

    private func updateWorkoutExercises() {
        if mode == .edit {
            program.exercises = makeOrderedExercises()
        } else {
            applySelectionIndicesForCreate()
            program.exercises = selectedExercises
        }
    }

    private func makeOrderedExercises() -> [WorkoutExercise] {
        var ordered = existingSelectedExercises()
        let newExercises = newSelectedExercises(from: ordered)
        applySelectionIndicesIfNeeded(for: newExercises, existing: ordered)
        ordered.append(contentsOf: newExercises)
        return ordered
    }

    private func existingSelectedExercises() -> [WorkoutExercise] {
        let selectedIds = Set(selectedExercises.map { $0.id })
        return program.exercises.filter { selectedIds.contains($0.id) }
    }

    private func newSelectedExercises(from ordered: [WorkoutExercise]) -> [WorkoutExercise] {
        let existingIds = Set(ordered.map { $0.id })
        return selectedExercises.filter { !existingIds.contains($0.id) }
    }

    private func applySelectionIndicesIfNeeded(for exercises: [WorkoutExercise], existing: [WorkoutExercise]) {
        let maxSelectionIndex = existing.map { $0.selectionIndex }.max() ?? 0
        var nextSelectionIndex = maxSelectionIndex
        for exercise in exercises where exercise.selectionIndex == 0 {
            nextSelectionIndex += 1
            exercise.selectionIndex = nextSelectionIndex
        }
    }

    private func applySelectionIndicesForCreate() {
        for (index, exercise) in selectedExercises.enumerated() {
            exercise.selectionIndex = index + 1
        }
    }

    private func persistProgram() async -> Bool {
        if mode == .create {
            await addProgramIfNeeded()
            return true
        }
        return await saveProgramEdits()
    }

    private func addProgramIfNeeded() async {
        if !programViewModel.customPrograms.contains(where: { $0.id == program.id }) {
            await programViewModel.addProgram(program)
        }
    }

    private func saveProgramEdits() async -> Bool {
        do {
            try await programService.save(program)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func finishSave() async {
        await load()
        didSave = true
    }
}
