import Foundation

@MainActor
protocol ProgramServiceType {
    func fetchPrograms() async throws -> [Program]
    func save(_ program: Program) async throws
    func deleteProgram(_ program: Program) async throws
    func reorderExercises(in program: Program, from source: IndexSet, to destination: Int) async throws
}
