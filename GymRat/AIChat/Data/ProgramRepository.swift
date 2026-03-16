import Foundation

protocol ProgramRepository {
    func fetchProgram(id: UUID?) -> ProgramModel?
    func fetchOrCreateExercise(name: String) -> ExerciseModel
    func save() throws
}
