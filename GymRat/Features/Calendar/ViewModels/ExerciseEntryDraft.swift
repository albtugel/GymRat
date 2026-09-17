import Foundation

/// What a row shows and what it still owes the store: the field texts for one day, the previous
/// day's values for reference, and the dirty / pending-save bookkeeping around them.
///
/// A plain value, so the save cycle (edit → checkout → persist or park as pending → restore) can be
/// tested without a store or a view.
struct ExerciseEntryDraft {
    typealias SetTexts = ExerciseEntryFormatter.SetTexts

    /// Entries whose save failed. Kept until a retry succeeds so a reload never silently drops them.
    struct PendingSave: Equatable {
        let date: Date
        let values: ExerciseLogValues
        let setsEdited: Bool
    }

    /// Entries handed out for saving, already marked clean in the draft.
    struct Checkout: Equatable {
        let date: Date
        let values: ExerciseLogValues
        let setsEdited: Bool
    }

    private(set) var setsCountText: String
    private(set) var current = SetTexts(reps: [], weights: [], durations: [])
    private(set) var previous = SetTexts(reps: [], weights: [], durations: [])
    /// The day the fields currently show.
    private(set) var day: Date
    private(set) var isDirty = false
    private(set) var setsEdited = false
    /// The day the unsaved entries belong to; set on the first edit, cleared by checkout.
    private(set) var editSessionDate: Date?
    private(set) var pendingSave: PendingSave?

    private let defaultSets: Int
    private let formatter: ExerciseEntryFormatter

    init(day: Date, defaultSets: Int, formatter: ExerciseEntryFormatter) {
        self.day = day.startOfDay
        self.defaultSets = defaultSets
        self.formatter = formatter
        self.setsCountText = String(ExerciseEntryFormatter.clampedSets(defaultSets))
    }

    var setsCount: Int {
        let typed = Int(setsCountText.trimmingCharacters(in: .whitespacesAndNewlines)) ?? defaultSets
        return ExerciseEntryFormatter.clampedSets(typed)
    }

    var hasUnsavedChanges: Bool {
        pendingSave != nil || isDirty || setsEdited
    }

    var values: ExerciseLogValues {
        formatter.values(from: current)
    }

    // MARK: - Showing a day

    /// Replaces the fields with a day's stored entries (or empty fields sized like the previous day),
    /// then puts back anything a failed save still holds for that day.
    mutating func show(day: Date, current currentLog: ExerciseLogValues?, previous previousLog: ExerciseLogValues?) {
        self.day = day.startOfDay
        setsCountText = String(ExerciseEntryFormatter.clampedSets((currentLog ?? previousLog)?.setCount ?? defaultSets))
        current = currentLog.map(formatter.texts(for:)) ?? emptyTexts()
        previous = previousLog.map(formatter.texts(for:)) ?? emptyTexts()
        isDirty = false
        setsEdited = false
        editSessionDate = nil
        normalize()
        restorePendingIfShown()
    }

    // MARK: - Editing

    mutating func beginEdit() {
        if editSessionDate == nil {
            editSessionDate = day
        }
    }

    /// An emptied field stays empty (and clean) until a count is typed; anything else is clamped.
    mutating func updateSetsCount(_ text: String) {
        let digits = ExerciseEntryFormatter.digits(text)
        if digits.isEmpty {
            setsCountText = ""
            return
        }
        guard let value = Int(digits) else { return }
        setsCountText = String(ExerciseEntryFormatter.clampedSets(value))
        setsEdited = true
        markEdited()
        normalize()
    }

    mutating func updateReps(_ text: String, at index: Int) {
        set(\.reps, to: formatter.sanitizedReps(text), at: index)
    }

    mutating func updateWeight(_ text: String, at index: Int) {
        set(\.weights, to: formatter.sanitizedWeight(text), at: index)
    }

    mutating func updateDuration(_ text: String, at index: Int) {
        set(\.durations, to: formatter.sanitizedDuration(text), at: index)
    }

    // MARK: - Saving

    /// Hands out the unsaved entries and marks the draft clean, so anything typed while the write is
    /// in flight stays dirty and goes out with the next save.
    mutating func checkout() -> Checkout? {
        guard isDirty || setsEdited, let date = editSessionDate else { return nil }
        normalize()
        let checkout = Checkout(date: date, values: values, setsEdited: setsEdited)
        isDirty = false
        setsEdited = false
        editSessionDate = nil
        return checkout
    }

    mutating func markSaved(_ checkout: Checkout) {
        // A newer write for the same day supersedes anything still waiting from an earlier failure.
        if let pending = pendingSave, pending.date.startOfDay == checkout.date.startOfDay {
            pendingSave = nil
        }
    }

    mutating func markSaveFailed(_ checkout: Checkout) {
        pendingSave = PendingSave(date: checkout.date, values: checkout.values, setsEdited: checkout.setsEdited)
    }

    mutating func markPendingSaved() {
        pendingSave = nil
    }

    // MARK: - Helpers

    /// Puts entries from a failed save back into the fields when the row shows their day, so the
    /// user sees exactly what is still unsaved and the next checkout picks it up again.
    private mutating func restorePendingIfShown() {
        guard let pending = pendingSave, pending.date.startOfDay == day else { return }
        pendingSave = nil
        setsCountText = String(ExerciseEntryFormatter.clampedSets(pending.values.setCount))
        current = formatter.texts(for: pending.values)
        normalize()
        isDirty = true
        setsEdited = pending.setsEdited
        editSessionDate = day
    }

    private mutating func set(_ column: WritableKeyPath<SetTexts, [String]>, to text: String, at index: Int) {
        guard current[keyPath: column].indices.contains(index) else { return }
        current[keyPath: column][index] = text
        markEdited()
    }

    private mutating func markEdited() {
        isDirty = true
        if editSessionDate == nil {
            editSessionDate = day
        }
    }

    private func emptyTexts() -> SetTexts {
        let empty = Array(repeating: "", count: setsCount)
        return SetTexts(reps: empty, weights: empty, durations: empty)
    }

    /// Pads or trims every column to the set count.
    private mutating func normalize() {
        let count = setsCount
        func fit(_ column: inout [String]) {
            if column.count < count {
                column.append(contentsOf: Array(repeating: "", count: count - column.count))
            } else if column.count > count {
                column = Array(column.prefix(count))
            }
        }
        fit(&current.reps); fit(&current.weights); fit(&current.durations)
        fit(&previous.reps); fit(&previous.weights); fit(&previous.durations)
    }
}
