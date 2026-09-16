import Foundation
import Observation

@Observable
@MainActor
final class ExerciseRowViewModel {
    private struct LogContext {
        let day: Date
        let dayStamp: Int
        let currentLog: ExerciseLogSnapshot?
        let previousLog: ExerciseLogSnapshot?
    }

    /// Entries whose save failed. Kept until a retry succeeds so a reload never silently drops them.
    private struct PendingSave {
        let date: Date
        let values: ExerciseLogValues
        let setsEdited: Bool
    }


    let programExercise: WorkoutExercise
    private(set) var repsBySetText: [String] = []
    private(set) var weightsBySetText: [String] = []
    private(set) var durationsBySetText: [String] = []
    private(set) var previousRepsBySetText: [String] = []
    private(set) var previousWeightsBySetText: [String] = []
    private(set) var previousDurationsBySetText: [String] = []
    private(set) var seed: ExerciseRepo.ExerciseSeed?
    private(set) var setsCountText: String
    private(set) var isLoadingLog: Bool = false
    private(set) var errorMessage: String?

    private var currentLog: ExerciseLogSnapshot?
    private var setsEditedForDay: Bool = false
    private var dataDate: Date
    private var wasFocused: Bool = false
    private var focusDate: Date?
    private var editSessionDate: Date?
    private var isDirty: Bool = false
    private var selectedDate: Date
    private var pendingSave: PendingSave?


    private let logStore: any ExerciseLogStoreType
    private let units: Units
    private let exerciseStore: any ExerciseStoreType

    init(
        programExercise: WorkoutExercise,
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
        self.setsCountText = String(max(1, programExercise.sets))
        self.dataDate = selectedDate.startOfDay
    }


    var setsCount: Int {
        let parsed = Int(setsCountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? programExercise.sets
        return min(10, max(1, parsed))
    }

    var inputType: ExerciseInputType {
        seed?.inputType ?? (isCardio ? .cardioDistance : .strength)
    }

    var isCardio: Bool {
        ExerciseMapper.category(for: programExercise.exercise) == .cardio
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

    enum SetRowColumn: String, Identifiable {
        case previousReps
        case previousWeight
        case previousDuration
        case currentReps
        case currentWeight
        case currentDuration

        var id: String { rawValue }
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


    func load() async {
        isLoadingLog = true
        defer { isLoadingLog = false }
        seed = await exerciseStore.getExerciseSeed(named: programExercise.exercise.name)
        do {
            let context = try await buildLogContext()
            // The selection may have moved on while the fetch was in flight; a newer load owns the row then.
            guard context.day == selectedDate.startOfDay else { return }
            applyLogContext(context)
            restorePendingSaveIfNeeded(for: context.day)
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
        let startsEdit = shouldStartEdit(isFocused: isFocused)
        let savesOnFocusLoss = shouldSaveOnFocusLoss(isFocused: isFocused)
        wasFocused = isFocused
        if startsEdit {
            beginEditSession()
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
        editSessionDate = dataDate
    }

    /// True while entries exist that have not reached the store yet.
    var hasUnsavedChanges: Bool {
        pendingSave != nil || isDirty || setsEditedForDay
    }


    func setsText() -> String {
        setsCountText
    }

    func updateSetsCountText(_ newValue: String) {
        let sanitized = sanitizeIntegerInput(newValue, allowDash: false)
        if sanitized.isEmpty {
            setsCountText = ""
            return
        }
        guard let value = Int(sanitized) else { return }
        setsCountText = String(min(10, max(1, value)))
        programExercise.sets = setsCount
        setsEditedForDay = true
        markEdited()
        normalizeArrays()
    }

    func repsText(at index: Int) -> String {
        text(at: index, in: repsBySetText)
    }

    func weightText(at index: Int) -> String {
        text(at: index, in: weightsBySetText)
    }

    func durationText(at index: Int) -> String {
        text(at: index, in: durationsBySetText)
    }

    func previousRepsText(at index: Int) -> String {
        text(at: index, in: previousRepsBySetText)
    }

    func previousWeightText(at index: Int) -> String {
        text(at: index, in: previousWeightsBySetText)
    }

    func previousDurationText(at index: Int) -> String {
        text(at: index, in: previousDurationsBySetText)
    }

    func updateRepsText(_ newValue: String, index: Int) {
        let sanitized = sanitizeIntegerInput(newValue, allowDash: false)
        updateArray(&repsBySetText, value: sanitized, index: index)
        markEdited()
    }

    func updateWeightText(_ newValue: String, index: Int) {
        let sanitized = isCardio
            ? sanitizeIntegerInput(newValue, allowDash: false)
            : sanitizeDecimalInput(newValue, maxFractionDigits: 2)
        updateArray(&weightsBySetText, value: sanitized, index: index)
        markEdited()
    }

    func updateDurationText(_ newValue: String, index: Int) {
        let sanitized = sanitizeDurationInput(newValue)
        updateArray(&durationsBySetText, value: sanitized, index: index)
        markEdited()
    }


    private var scope: ExerciseLogScope {
        ExerciseLogScope(
            programExerciseID: programExercise.id,
            exerciseID: programExercise.exercise.id,
            sharedHistory: programExercise.sharedHistory
        )
    }

    private func buildLogContext() async throws -> LogContext {
        let day = selectedDate.startOfDay
        let dayStamp = ExerciseLogHelper.makeDayStamp(for: day)
        let logs = try await logStore.fetchLogs(in: scope)
        let currentLog = logs.first { $0.dayStamp == dayStamp }
        let previousLog = logs
            .filter { $0.dayStamp < dayStamp && $0.values.hasValues }
            .max { $0.dayStamp < $1.dayStamp }
        return LogContext(day: day, dayStamp: dayStamp, currentLog: currentLog, previousLog: previousLog)
    }

    private func applyLogContext(_ context: LogContext) {
        currentLog = context.currentLog
        setsCountText = makeSetsCountText(currentLog: context.currentLog, previousLog: context.previousLog)
        setsEditedForDay = false
        applyCurrentLog(context.currentLog)
        applyPreviousLog(context.previousLog)
        normalizeArrays()
        dataDate = context.day
        editSessionDate = nil
        isDirty = false
    }

    private func makeSetsCountText(
        currentLog: ExerciseLogSnapshot?,
        previousLog: ExerciseLogSnapshot?
    ) -> String {
        if let log = currentLog {
            return String(max(1, log.values.setCount))
        }
        if let log = previousLog {
            return String(max(1, log.values.setCount))
        }
        return String(max(1, programExercise.sets))
    }

    private func applyCurrentLog(_ log: ExerciseLogSnapshot?) {
        if let log {
            repsBySetText = log.values.repsBySet.map { formatRepsValue($0) }
            weightsBySetText = log.values.weightsBySet.map { formatWeightValue($0) }
            durationsBySetText = log.values.durationsBySet.map { formatDurationValue($0) }
        } else {
            repsBySetText = Array(repeating: "", count: setsCount)
            weightsBySetText = Array(repeating: "", count: setsCount)
            durationsBySetText = Array(repeating: "", count: setsCount)
        }
    }

    private func applyPreviousLog(_ log: ExerciseLogSnapshot?) {
        if let log {
            previousRepsBySetText = log.values.repsBySet.map { formatRepsValue($0) }
            previousWeightsBySetText = log.values.weightsBySet.map { formatWeightValue($0) }
            previousDurationsBySetText = log.values.durationsBySet.map { formatDurationValue($0) }
        } else {
            previousRepsBySetText = Array(repeating: "", count: setsCount)
            previousWeightsBySetText = Array(repeating: "", count: setsCount)
            previousDurationsBySetText = Array(repeating: "", count: setsCount)
        }
    }

    private func saveCurrentLogIfNeeded() async {
        await retryPendingSave()
        guard isDirty || setsEditedForDay, let targetDate = editSessionDate else { return }
        normalizeArrays()
        let values = makeLogValues()
        let setsEdited = setsEditedForDay
        // Cleared before suspending, so entries typed while the write is in flight stay dirty and go
        // out with the next save instead of being marked clean by this one.
        isDirty = false
        setsEditedForDay = false
        editSessionDate = nil
        do {
            try await persist(values, for: targetDate, setsEdited: setsEdited)
            // A newer write for the same day supersedes anything still waiting from an earlier failure.
            if let pending = pendingSave, pending.date.startOfDay == targetDate.startOfDay {
                pendingSave = nil
            }
            errorMessage = nil
        } catch {
            pendingSave = PendingSave(date: targetDate, values: values, setsEdited: setsEdited)
            reportSaveFailure(error)
        }
    }

    private func retryPendingSave() async {
        guard let pending = pendingSave else { return }
        do {
            try await persist(pending.values, for: pending.date, setsEdited: pending.setsEdited)
            pendingSave = nil
            errorMessage = nil
        } catch {
            reportSaveFailure(error)
        }
    }

    private func persist(_ values: ExerciseLogValues, for date: Date, setsEdited: Bool) async throws {
        let day = date.startOfDay
        let saved = try await logStore.saveLog(
            in: scope,
            day: day,
            sets: setsEdited ? values.setCount : nil,
            values: values,
            keepEmpty: setsEdited
        )
        if ExerciseLogHelper.makeDayStamp(for: dataDate) == ExerciseLogHelper.makeDayStamp(for: day) {
            currentLog = saved
        }
    }

    private func reportSaveFailure(_ error: any Error) {
        AppLog.exerciseLogs.error(
            "Failed to save log for \(self.programExercise.exercise.name, privacy: .public): \(String(describing: error), privacy: .public)"
        )
        errorMessage = String(localized: "exercise_log_save_failed")
    }

    /// Puts entries from a failed save back into the fields when the row returns to their day, so the
    /// user sees exactly what is still unsaved and the next save picks it up again.
    private func restorePendingSaveIfNeeded(for day: Date) {
        guard let pending = pendingSave, pending.date.startOfDay == day else { return }
        pendingSave = nil
        setsCountText = String(max(1, pending.values.setCount))
        repsBySetText = pending.values.repsBySet.map { formatRepsValue($0) }
        weightsBySetText = pending.values.weightsBySet.map { formatWeightValue($0) }
        durationsBySetText = pending.values.durationsBySet.map { formatDurationValue($0) }
        normalizeArrays()
        isDirty = true
        setsEditedForDay = pending.setsEdited
        editSessionDate = day
    }

    private func makeLogValues() -> ExerciseLogValues {
        ExerciseLogValues(
            repsBySet: repsBySetText.map { parseRepsText($0) },
            weightsBySet: weightsBySetText.map { parseWeightText($0) },
            durationsBySet: durationsBySetText.map { parseDurationText($0) }
        )
    }


    private func normalizeArrays() {
        repsBySetText = normalize(repsBySetText, fill: "")
        weightsBySetText = normalize(weightsBySetText, fill: "")
        durationsBySetText = normalize(durationsBySetText, fill: "")
        previousRepsBySetText = normalize(previousRepsBySetText, fill: "")
        previousWeightsBySetText = normalize(previousWeightsBySetText, fill: "")
        previousDurationsBySetText = normalize(previousDurationsBySetText, fill: "")
    }

    private func normalize(_ array: [String], fill: String) -> [String] {
        var result = array
        if result.count < setsCount {
            result.append(contentsOf: Array(repeating: fill, count: setsCount - result.count))
        } else if result.count > setsCount {
            result = Array(result.prefix(setsCount))
        }
        return result
    }


    private func formatRepsValue(_ value: Int) -> String {
        guard value > 0 else { return "" }
        if isCardio {
            let displayed = units.displayDistance(value)
            return displayed.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(displayed))
                : String(format: "%.2f", displayed)
        }
        return String(value)
    }

    private func formatWeightValue(_ value: Double) -> String {
        guard value > 0 else { return "" }
        return formatWeight(isCardio ? value : units.displayWeight(value))
    }

    private func formatDurationValue(_ seconds: Int) -> String {
        guard seconds > 0 else { return "" }
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func parseRepsText(_ text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if isCardio {
            let value = Double(trimmed) ?? 0
            return units.storeDistance(value)
        }
        return Int(trimmed) ?? 0
    }

    private func parseWeightText(_ text: String) -> Double {
        let value = parseWeight(text) ?? 0
        return isCardio ? value : units.storeWeight(value)
    }

    private func parseDurationText(_ text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: ":")
        if parts.count == 2, let mins = Int(parts[0]), let secs = Int(parts[1]) {
            return mins * 60 + secs
        }
        return Int(trimmed) ?? 0
    }

    private func parseWeight(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    private func formatWeight(_ weight: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        return formatter.string(from: NSNumber(value: weight)) ?? String(weight)
    }


    private func sanitizeDecimalInput(_ text: String, maxFractionDigits: Int) -> String {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        var result = ""
        var hasDot = false
        var fractionCount = 0

        for ch in normalized {
            if ch.isNumber {
                if hasDot {
                    if fractionCount < maxFractionDigits {
                        result.append(ch)
                        fractionCount += 1
                    }
                } else {
                    result.append(ch)
                }
            } else if ch == "." && !hasDot {
                hasDot = true
                result.append(ch)
            }
        }

        if result == "." { return "0." }
        return result
    }

    private func sanitizeIntegerInput(_ text: String, allowDash: Bool) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if allowDash && trimmed == "-" { return "-" }
        return trimmed.filter { $0.isNumber }
    }

    private func sanitizeDurationInput(_ text: String) -> String {
        var sanitized = text.filter { $0.isNumber || $0 == ":" }
        let parts = sanitized.split(separator: ":", maxSplits: 1)
        if parts.count == 2 {
            let mins = String(parts[0].prefix(2))
            let secs = String(parts[1].prefix(2))
            sanitized = "\(mins):\(secs)"
        } else {
            sanitized = String(sanitized.prefix(2))
        }
        return sanitized
    }


    private func text(at index: Int, in array: [String]) -> String {
        index < array.count ? array[index] : ""
    }

    private func updateArray(_ array: inout [String], value: String, index: Int) {
        if index < array.count {
            array[index] = value
        }
    }

    private func markEdited() {
        isDirty = true
        if editSessionDate == nil {
            editSessionDate = dataDate
        }
    }

    private func isRowFocused(_ field: ExerciseField?) -> Bool {
        switch field {
        case .sets(let id):
            return id == programExercise.id
        case .reps(let id, _):
            return id == programExercise.id
        case .weight(let id, _):
            return id == programExercise.id
        case .duration(let id, _):
            return id == programExercise.id
        default:
            return false
        }
    }

    private func shouldStartEdit(isFocused: Bool) -> Bool {
        !wasFocused && isFocused
    }

    private func shouldSaveOnFocusLoss(isFocused: Bool) -> Bool {
        wasFocused && !isFocused && focusDate == dataDate
    }

    private func beginEditSession() {
        focusDate = dataDate
        if editSessionDate == nil {
            editSessionDate = dataDate
        }
    }
}
