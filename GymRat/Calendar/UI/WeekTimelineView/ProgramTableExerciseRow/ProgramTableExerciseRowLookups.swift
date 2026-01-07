import SwiftUI
import SwiftData

extension ProgramTableExerciseRowView {
    // MARK: - Lookups
    func fetchOrCreateExerciseInContext() -> ExerciseModel {
        let name = programExercise.exercise.name
        let descriptor = FetchDescriptor<ExerciseModel>(predicate: #Predicate<ExerciseModel> { $0.name == name })
        if let existing = (try? context.fetch(descriptor))?.first {
            return existing
        }

        let newExercise = ExerciseModel(name: name, category: programExercise.exercise.category)
        context.insert(newExercise)
        return newExercise
    }

    func matchesExercise(_ log: ProgramExerciseLog) -> Bool {
        guard let name = log.exerciseName, !name.isEmpty else { return false }
        return name.localizedCaseInsensitiveCompare(programExercise.exercise.name) == .orderedSame
    }

    func fetchLog(for dayStamp: Int) -> ProgramExerciseLog? {
        let name = programExercise.exercise.name
        let predicate = #Predicate<ProgramExerciseLog> { log in
            log.exerciseName == name && log.dayStamp == dayStamp
        }
        let descriptor = FetchDescriptor<ProgramExerciseLog>(predicate: predicate)
        return (try? context.fetch(descriptor))?.first
    }
}
