import Foundation

@MainActor
protocol ProgramServiceProtocol {
    func fetchPrograms() async throws -> [Program]
    func saveProgram(_ program: Program) async throws
    func deleteProgram(_ program: Program) async throws
    func reorderExercises(in program: Program, from source: IndexSet, to destination: Int) async throws
}
