import SwiftUI

extension ProgramTableExerciseRowView {
    // MARK: - UI Helpers
    func isRowFocused(_ field: ProgramTableFocusField?) -> Bool {
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

    func logScore(_ log: ProgramExerciseLog) -> Int {
        let repsCount = log.repsBySet.filter { $0 > 0 }.count
        let weightsCount = log.weightsBySet.filter { $0 > 0 }.count
        let durationsCount = log.durationsBySet.filter { $0 > 0 }.count
        return repsCount + weightsCount + durationsCount
    }

    func hasValues(_ log: ProgramExerciseLog) -> Bool {
        log.repsBySet.contains { $0 > 0 }
            || log.weightsBySet.contains { $0 > 0 }
            || log.durationsBySet.contains { $0 > 0 }
    }
}
