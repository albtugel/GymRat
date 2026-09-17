import Foundation
import Observation

/// One exercise row of the selected day: loads the day's entries, forwards edits to the draft and
/// writes the draft through the log store. Text conversion lives in `ExerciseEntryFormatter`; the
/// editable state and the pending-save bookkeeping in `ExerciseEntryDraft`.
@Observable
@MainActor
final class ExerciseRowViewModel {
    enum SetRowColumn: String, Identifiable {
        case previousReps
        case previousWeight
        case previousDuration
        case currentReps
        case currentWeight
        case currentDuration

        var id: String { rawValue }
    }

    let programExercise: WorkoutExerciseSnapshot
    private(set) var seed: ExerciseRepo.ExerciseSeed?
    private(set) var isLoadingLog: Bool = false
    private(set) var errorMessage: String?
    private(set) var draft: ExerciseEntryDraft

    private var selectedDate: Date
    private var wasFocused: Bool = false
    private var focusDate: Date?

    private let formatter: ExerciseEntryFormatter
    private let logStore: any ExerciseLogStoreType
    private let units: Units
    private let exerciseStore: any ExerciseStoreType

    init(
        programExercise: WorkoutExerciseSnapshot,
        selectedDate: Date,
        logStore: any ExerciseLogStoreType,
        units: Units,
        exerciseStore: any ExerciseStoreType
    ) {
        self.programExercise = programExercise
        self.selectedDate = selectedDate
        self.logStore = logStore
        self.units = units
        self.exerciseStore = exerciseStore
        formatter = ExerciseEntryFormatter(units: units, isCardio: programExercise.exercise.category == .cardio)
        draft = ExerciseEntryDraft(day: selectedDate, defaultSets: programExercise.sets, formatter: formatter)
    }

    // MARK: - Presentation

    var setsCount: Int {
        draft.setsCount
    }

    var isCardio: Bool {
        formatter.isCardio
    }

    var inputType: ExerciseInputType {
        seed?.inputType ?? (isCardio ? .cardioDistance : .strength)
    }

    var showsDuration: Bool {
        inputType == .cardioDistance || inputType == .cardioJump || inputType == .timed
    }

    var showsWeight: Bool {
        inputType == .strength || inputType == .timed
    }

    var showsReps: Bool {
        inputType != .timed
    }

    var setRowColumns: [SetRowColumn] {
        var columns: [SetRowColumn] = [.previousReps]
        if showsWeight {
            columns.append(.previousWeight)
        }
        if showsDuration {
            columns.append(.previousDuration)
        }
        columns.append(.currentReps)
        if showsWeight {
            columns.append(.currentWeight)
        }
        if showsDuration {
            columns.append(.currentDuration)
        }
        return columns
    }

    var weightPlaceholder: String {
        units.currentWeightUnit.label
    }

    var durationPlaceholder: String {
        String(localized: "dur_label")
    }

    var repsPlaceholder: String {
        switch inputType {
        case .strength: return String(localized: "reps_label")
        case .cardioDistance: return units.currentDistanceUnit.label
        case .cardioJump: return String(localized: "jumps_label")
        case .timed: return String(localized: "reps_label")
        }
    }

    var setsTitle: String {
        switch inputType {
        case .strength, .timed: return String(localized: "sets_label")
        case .cardioDistance, .cardioJump: return String(localized: "rounds_label")
        }
    }

    /// True while entries exist that have not reached the store yet.
    var hasUnsavedChanges: Bool {
        draft.hasUnsavedChanges
    }

    // MARK: - Field access

    func setsText() -> String {
        draft.setsCountText
    }

    func repsText(at index: Int) -> String {
        text(at: index, in: draft.current.reps)
    }

    func weightText(at index: Int) -> String {
        text(at: index, in: draft.current.weights)
    }

    func durationText(at index: Int) -> String {
        text(at: index, in: draft.current.durations)
    }

    func previousRepsText(at index: Int) -> String {
        text(at: index, in: draft.previous.reps)
    }

    func previousWeightText(at index: Int) -> String {
        text(at: index, in: draft.previous.weights)
    }

    func previousDurationText(at index: Int) -> String {
        text(at: index, in: draft.previous.durations)
    }

    func updateSetsCountText(_ newValue: String) {
        draft.updateSetsCount(newValue)
    }

    func updateRepsText(_ newValue: String, index: Int) {
        draft.updateReps(newValue, at: index)
    }

    func updateWeightText(_ newValue: String, index: Int) {
        draft.updateWeight(newValue, at: index)
    }

    func updateDurationText(_ newValue: String, index: Int) {
        draft.updateDuration(newValue, at: index)
    }

    // MARK: - Lifecycle

    func load() async {
        isLoadingLog = true
        defer { isLoadingLog = false }
        seed = await exerciseStore.getExerciseSeed(named: programExercise.exercise.name)
        let day = selectedDate.startOfDay
        do {
            let logs = try await logStore.fetchLogs(in: scope)
            // The selection may have moved on while the fetch was in flight; a newer load owns the row then.
            guard day == selectedDate.startOfDay else { return }
            let dayStamp = ExerciseLogHelper.makeDayStamp(for: day)
            let current = logs.first { $0.dayStamp == dayStamp }?.values
            let previous = logs
                .filter { $0.dayStamp < dayStamp && $0.values.hasValues }
                .max { $0.dayStamp < $1.dayStamp }?
                .values
            draft.show(day: day, current: current, previous: previous)
        } catch {
            AppLog.exerciseLogs.error(
                "Failed to load logs for \(self.programExercise.exercise.name, privacy: .public): \(String(describing: error), privacy: .public)"
            )
            errorMessage = String(localized: "exercise_log_load_failed")
        }
    }

    func updateSelectedDate(_ date: Date) async {
        await saveCurrentLogIfNeeded()
        selectedDate = date
        await load()
    }

    func handleFocusChange(_ newValue: ExerciseField?) async {
        let isFocused = isRowFocused(newValue)
        let startsEdit = !wasFocused && isFocused
        let savesOnFocusLoss = wasFocused && !isFocused && focusDate == draft.day
        wasFocused = isFocused
        if startsEdit {
            focusDate = draft.day
            draft.beginEdit()
        } else if savesOnFocusLoss {
            await saveCurrentLogIfNeeded()
        }
    }

    /// Writes any unsaved entries. Called when the row leaves the screen, when the calendar flushes
    /// all rows, and from the Retry button after a failed save.
    func saveIfNeeded() async {
        await saveCurrentLogIfNeeded()
    }

    func handleDragStart() {
        draft.beginEdit()
    }

    // MARK: - Saving

    private var scope: ExerciseLogScope {
        ExerciseLogScope(
            programExerciseID: programExercise.id,
            exerciseID: programExercise.exercise.id,
            sharedHistory: programExercise.sharedHistory
        )
    }

    private func saveCurrentLogIfNeeded() async {
        await retryPendingSave()
        guard let checkout = draft.checkout() else { return }
        do {
            try await persist(checkout.values, for: checkout.date, setsEdited: checkout.setsEdited)
            draft.markSaved(checkout)
            errorMessage = nil
        } catch {
            draft.markSaveFailed(checkout)
            reportSaveFailure(error)
        }
    }

    private func retryPendingSave() async {
        guard let pending = draft.pendingSave else { return }
        do {
            try await persist(pending.values, for: pending.date, setsEdited: pending.setsEdited)
            draft.markPendingSaved()
            errorMessage = nil
        } catch {
            reportSaveFailure(error)
        }
    }

    private func persist(_ values: ExerciseLogValues, for date: Date, setsEdited: Bool) async throws {
        _ = try await logStore.saveLog(
            in: scope,
            day: date.startOfDay,
            sets: setsEdited ? values.setCount : nil,
            values: values,
            keepEmpty: setsEdited
        )
    }

    private func reportSaveFailure(_ error: any Error) {
        AppLog.exerciseLogs.error(
            "Failed to save log for \(self.programExercise.exercise.name, privacy: .public): \(String(describing: error), privacy: .public)"
        )
        errorMessage = String(localized: "exercise_log_save_failed")
    }

    // MARK: - Helpers

    private func text(at index: Int, in column: [String]) -> String {
        column.indices.contains(index) ? column[index] : ""
    }

    private func isRowFocused(_ field: ExerciseField?) -> Bool {
        switch field {
        case .sets(let id), .reps(let id, _), .weight(let id, _), .duration(let id, _):
            return id == programExercise.id
        case nil:
            return false
        }
    }
}
