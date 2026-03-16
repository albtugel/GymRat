import Foundation
import SwiftData

struct SwiftDataProgramRepository: ProgramRepository {
    let context: ModelContext

    func fetchProgram(id: UUID?) -> ProgramModel? {
        guard let id else {
            let descriptor = FetchDescriptor<ProgramModel>()
            return (try? context.fetch(descriptor))?.first
        }

        let descriptor = FetchDescriptor<ProgramModel>(predicate: #Predicate<ProgramModel> { $0.id == id })
        return (try? context.fetch(descriptor))?.first
    }

    func fetchOrCreateExercise(name: String) -> ExerciseModel {
        let descriptor = FetchDescriptor<ExerciseModel>(predicate: #Predicate<ExerciseModel> { $0.name == name })
        if let existing = (try? context.fetch(descriptor))?.first {
            return existing
        }

        let newExercise = ExerciseModel(name: name, category: .strength)
        context.insert(newExercise)
        return newExercise
    }

    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
