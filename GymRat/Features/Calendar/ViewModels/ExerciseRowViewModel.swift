import Foundation
import Observation

@Observable
@MainActor
final class ExerciseRowViewModel {
    private struct LogContext {
        let day: Date
        let dayStamp: Int
        let currentLog: ExerciseLog?
        let previousLog: ExerciseLog?
    }

    private struct LogPayload {
        let reps: [Int]
        let weights: [Double]
        let durations: [Int]
        let hasValues: Bool
    }

    // MARK: - State
    let programExercise: WorkoutExercise
    private(set) var repsBySetText: [String] = []
    private(set) var weightsBySetText: [String] = []
    private(set) var durationsBySetText: [String] = []
    private(set) var previousRepsBySetText: [String] = []
    private(set) var previousWeightsBySetText: [String] = []
    private(set) var previousDurationsBySetText: [String] = []
    private(set) var setsCountText: String
    private(set) var isLoadingLog: Bool = false
    private(set) var errorMessage: String?

    private var currentLog: ExerciseLog?
    private var setsEditedForDay: Bool = false
    private var dataDate: Date
    private var wasFocused: Bool = false
    private var focusDate: Date?
    private var editSessionDate: Date?
    private var isDirty: Bool = false
    private var selectedDate: Date

    // MARK: - Dependencies
    private let logService: ExerciseLogServiceType
    private let units: Units
    private let exerciseStore: ExerciseRepo

    init(
        programExercise: WorkoutExercise,
        selectedDate: Date,
        logService: ExerciseLogServiceType,
        units: Units,
        exerciseStore: ExerciseRepo
    ) {
        self.programExercise = programExercise
        self.selectedDate = selectedDate
        self.logService = logService
        self.units = units
        self.exerciseStore = exerciseStore
        self.setsCountText = String(max(1, programExercise.sets))
        self.dataDate = selectedDate.startOfDay
    }

    // MARK: - Derived
    var setsCount: Int {
        let parsed = Int(setsCountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? programExercise.sets
        return min(10, max(1, parsed))
    }

    var seed: ExerciseRepo.ExerciseSeed? {
        exerciseStore.seeds.first { $0.name == programExercise.exercise.name }
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

    // MARK: - Intents
    func load() async {
        isLoadingLog = true
        defer { isLoadingLog = false }
        let context = await buildLogContext()
        applyLogContext(context)
    }

    func updateSelectedDate(_ date: Date) async {
        await saveCurrentLogIfNeeded()
        selectedDate = date
        await load()
    }

    func handleFocusChange(_ newValue: ExerciseField?) async {
        let isFocused = isRowFocused(newValue)
        if shouldStartEdit(isFocused: isFocused) {
            beginEditSession()
        } else if shouldSaveOnFocusLoss(isFocused: isFocused) {
            await saveCurrentLogIfNeeded()
        }
        wasFocused = isFocused
    }

    func handleDisappear() async {
        await saveCurrentLogIfNeeded()
    }

    func handleDragStart() {
        editSessionDate = dataDate
    }

    // MARK: - Bindings
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

    // MARK: - Log Loading
    private func buildLogContext() async -> LogContext {
        let day = selectedDate.startOfDay
        let logs = await fetchLogs()
        await normalizeLogDatesIfNeeded(logs)
        let dayStamp = ExerciseLogHelper.makeDayStamp(for: day)
        let currentLog = await selectCurrentLog(from: logs, dayStamp: dayStamp)
        let previousLog = selectPreviousLog(from: logs, dayStamp: dayStamp)
        return LogContext(day: day, dayStamp: dayStamp, currentLog: currentLog, previousLog: previousLog)
    }

    private func fetchLogs() async -> [ExerciseLog] {
        (try? await logService.fetchLogs(
            programExerciseId: programExercise.id,
            exerciseId: programExercise.exercise.id,
            sharedHistory: programExercise.sharedHistory
        )) ?? []
    }

    private func selectPreviousLog(from logs: [ExerciseLog], dayStamp: Int) -> ExerciseLog? {
        logs
            .filter { $0.dayStamp < dayStamp && hasValues($0) }
            .sorted { $0.dayStamp > $1.dayStamp }
            .first
    }

    private func selectCurrentLog(
        from logs: [ExerciseLog],
        dayStamp: Int
    ) async -> ExerciseLog? {
        let sameDayLogs = logs.filter { $0.dayStamp == dayStamp }
        if sameDayLogs.count <= 1 {
            return sameDayLogs.first
        }
        let sorted = sameDayLogs.sorted { logScore($0) > logScore($1) }
        let keep = sorted.first
        await deleteDuplicateLogs(sorted.dropFirst())
        return keep
    }

    private func deleteDuplicateLogs(_ logs: ArraySlice<ExerciseLog>) async {
        for log in logs {
            try? await logService.deleteLog(log)
        }
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
        currentLog: ExerciseLog?,
        previousLog: ExerciseLog?
    ) -> String {
        if let log = currentLog {
            return String(max(1, max(log.repsBySet.count, max(log.weightsBySet.count, log.durationsBySet.count))))
        }
        if let log = previousLog {
            return String(max(1, max(log.repsBySet.count, max(log.weightsBySet.count, log.durationsBySet.count))))
        }
        return String(max(1, programExercise.sets))
    }

    private func applyCurrentLog(_ log: ExerciseLog?) {
        if let log {
            repsBySetText = log.repsBySet.map { formatRepsValue($0) }
            weightsBySetText = log.weightsBySet.map { formatWeightValue($0) }
            durationsBySetText = log.durationsBySet.map { formatDurationValue($0) }
        } else {
            repsBySetText = Array(repeating: "", count: setsCount)
            weightsBySetText = Array(repeating: "", count: setsCount)
            durationsBySetText = Array(repeating: "", count: setsCount)
        }
    }

    private func applyPreviousLog(_ log: ExerciseLog?) {
        if let log {
            previousRepsBySetText = log.repsBySet.map { formatRepsValue($0) }
            previousWeightsBySetText = log.weightsBySet.map { formatWeightValue($0) }
            previousDurationsBySetText = log.durationsBySet.map { formatDurationValue($0) }
        } else {
            previousRepsBySetText = Array(repeating: "", count: setsCount)
            previousWeightsBySetText = Array(repeating: "", count: setsCount)
            previousDurationsBySetText = Array(repeating: "", count: setsCount)
        }
    }

    private func normalizeLogDatesIfNeeded(_ logs: [ExerciseLog]) async {
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
        if didChange {
            try? await logService.saveChanges()
        }
    }

    // MARK: - Save
    private func saveCurrentLogIfNeeded() async {
        guard isDirty || setsEditedForDay else { return }
        guard let targetDate = editSessionDate else { return }
        await saveCurrentLog(for: targetDate)
    }

    private func saveCurrentLog(for date: Date) async {
        normalizeArrays()
        let payload = makeLogPayload()
        let day = date.startOfDay
        let dayStamp = ExerciseLogHelper.makeDayStamp(for: day)
        let logForDay = await fetchLog(for: dayStamp)
        await updateLog(logForDay, day: day, dayStamp: dayStamp, payload: payload)
        await syncCurrentLog(dayStamp: dayStamp, logForDay: logForDay)
        isDirty = false
        setsEditedForDay = false
        editSessionDate = nil
    }

    private func makeLogPayload() -> LogPayload {
        let reps = repsBySetText.map { parseRepsText($0) }
        let weights = weightsBySetText.map { parseWeightText($0) }
        let durations = durationsBySetText.map { parseDurationText($0) }
        let hasValues = reps.contains { $0 > 0 } || weights.contains { $0 > 0 } || durations.contains { $0 > 0 }
        return LogPayload(reps: reps, weights: weights, durations: durations, hasValues: hasValues)
    }

    private func fetchLog(for dayStamp: Int) async -> ExerciseLog? {
        try? await logService.fetchLog(
            programExerciseId: programExercise.id,
            exerciseId: programExercise.exercise.id,
            sharedHistory: programExercise.sharedHistory,
            dayStamp: dayStamp
        )
    }

    private func updateLog(
        _ log: ExerciseLog?,
        day: Date,
        dayStamp: Int,
        payload: LogPayload
    ) async {
        if let log {
            await updateExistingLog(log, day: day, dayStamp: dayStamp, payload: payload)
        } else if payload.hasValues || setsEditedForDay {
            await createLog(day: day, dayStamp: dayStamp, payload: payload)
        }
    }

    private func updateExistingLog(
        _ log: ExerciseLog,
        day: Date,
        dayStamp: Int,
        payload: LogPayload
    ) async {
        if payload.hasValues || setsEditedForDay {
            log.date = day
            log.dayStamp = dayStamp
            log.programExercise = programExercise
            log.exerciseName = programExercise.exercise.name
            log.repsBySet = payload.reps
            log.weightsBySet = payload.weights
            log.durationsBySet = payload.durations
            try? await logService.saveChanges()
        } else {
            try? await logService.deleteLog(log)
        }
    }

    private func createLog(day: Date, dayStamp: Int, payload: LogPayload) async {
        let newLog = ExerciseLog(
            programExercise: programExercise,
            exerciseName: programExercise.exercise.name,
            date: day,
            dayStamp: dayStamp,
            repsBySet: payload.reps,
            weightsBySet: payload.weights,
            durationsBySet: payload.durations
        )
        try? await logService.insertLog(newLog)
    }

    private func syncCurrentLog(dayStamp: Int, logForDay: ExerciseLog?) async {
        let dataStamp = ExerciseLogHelper.makeDayStamp(for: dataDate)
        if let saved = logForDay, saved.dayStamp == dataStamp {
            currentLog = saved
        } else if dataStamp == dayStamp {
            currentLog = await fetchLog(for: dayStamp)
        }
    }

    // MARK: - Normalization
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

    // MARK: - Formatting
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

    // MARK: - Input Sanitizers
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

    // MARK: - Helpers
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

    private func logScore(_ log: ExerciseLog) -> Int {
        let repsCount = log.repsBySet.filter { $0 > 0 }.count
        let weightsCount = log.weightsBySet.filter { $0 > 0 }.count
        let durationsCount = log.durationsBySet.filter { $0 > 0 }.count
        return repsCount + weightsCount + durationsCount
    }

    private func hasValues(_ log: ExerciseLog) -> Bool {
        log.repsBySet.contains { $0 > 0 }
            || log.weightsBySet.contains { $0 > 0 }
            || log.durationsBySet.contains { $0 > 0 }
    }
}
