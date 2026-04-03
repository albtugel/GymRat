import Foundation
import SwiftData

@MainActor
final class ProgramService: ProgramServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchPrograms() async throws -> [Program] {
        let descriptor = FetchDescriptor<ProgramModel>()
        let programs = try modelContext.fetch(descriptor)
        var didUpdateSelectionIndex = false
        for program in programs {
            let maxSelectionIndex = program.exercises.map { $0.selectionIndex }.max() ?? 0
            var nextSelectionIndex = maxSelectionIndex
            for exercise in program.exercises where exercise.selectionIndex == 0 {
                nextSelectionIndex += 1
                exercise.selectionIndex = nextSelectionIndex
                didUpdateSelectionIndex = true
            }
        }
        if didUpdateSelectionIndex && modelContext.hasChanges {
            try modelContext.save()
        }
        return programs
    }

    func saveProgram(_ program: Program) async throws {
        if program.modelContext == nil {
            modelContext.insert(program)
        }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    func deleteProgram(_ program: Program) async throws {
        modelContext.delete(program)
        try modelContext.save()
    }

    func reorderExercises(in program: Program, from source: IndexSet, to destination: Int) async throws {
        let _ = (source, destination)
        // Assumes the caller already updated program.exercises order.
        for (index, exercise) in program.exercises.enumerated() {
            let newIndex = index + 1
            if exercise.selectionIndex != newIndex {
                exercise.selectionIndex = newIndex
            }
        }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
