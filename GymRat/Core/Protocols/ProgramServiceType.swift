import Foundation

@MainActor
protocol ProgramServiceType {
    func fetchPrograms() throws -> [Program]
    func save(_ program: Program) throws
    func deleteProgram(_ program: Program) throws
    func reorderExercises(in program: Program, from source: IndexSet, to destination: Int) throws
}
