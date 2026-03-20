import SwiftUI
import SwiftData

extension ProgramTableExerciseRowView {
    // MARK: - Lookups
    func matchesExercise(_ log: ProgramExerciseLog) -> Bool {
        if programExercise.sharedHistory {
            if log.programExercise.exercise.id == programExercise.exercise.id {
                return true
            }
        } else if log.programExercise.id == programExercise.id {
            return true
        }

        return false
    }

    func fetchLog(for dayStamp: Int) -> ProgramExerciseLog? {
        let predicate: Predicate<ProgramExerciseLog>
        if programExercise.sharedHistory {
            let exerciseId = programExercise.exercise.id
            predicate = #Predicate<ProgramExerciseLog> { log in
                log.programExercise.exercise.id == exerciseId && log.dayStamp == dayStamp
            }
        } else {
            let programExerciseId = programExercise.id
            predicate = #Predicate<ProgramExerciseLog> { log in
                log.programExercise.id == programExerciseId && log.dayStamp == dayStamp
            }
        }
        let descriptor = FetchDescriptor<ProgramExerciseLog>(predicate: predicate)
        return (try? context.fetch(descriptor))?.first
    }
}
