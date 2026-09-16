import Foundation
import Observation

/// Lets the calendar flush unsaved set entries of every row on screen at explicit moments (the day
/// changes, the keyboard is dismissed) and wait for the writes, instead of broadcasting a notification
/// and hoping each row hears it. Rows register while visible; they are held weakly so registration
/// never extends a row's lifetime.
@Observable
@MainActor
final class ExerciseLogSaveCoordinator {
    private struct Entry {
        weak var row: ExerciseRowViewModel?
    }

    @ObservationIgnored private var rows: [ObjectIdentifier: Entry] = [:]

    var registeredRowCount: Int {
        rows.values.filter { $0.row != nil }.count
    }

    func register(_ row: ExerciseRowViewModel) {
        rows[ObjectIdentifier(row)] = Entry(row: row)
    }

    func unregister(_ row: ExerciseRowViewModel) {
        rows[ObjectIdentifier(row)] = nil
    }

    /// Saves every registered row and returns once all writes have finished.
    func saveAll() {
        rows = rows.filter { $0.value.row != nil }
        for row in rows.values.compactMap(\.row) {
            row.saveIfNeeded()
        }
    }
}
