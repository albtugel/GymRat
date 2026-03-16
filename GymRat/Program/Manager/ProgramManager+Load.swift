import Foundation
import SwiftData

extension ProgramManager {
    // MARK: Load all programs and assignments
    func loadPrograms(context: ModelContext) {
        do {
            programs = try context.fetch(FetchDescriptor<ProgramModel>())
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
            if didUpdateSelectionIndex, context.hasChanges {
                try? context.save()
            }
            customPrograms = programs
            loadDayPrograms(context: context)
        } catch {
            print("Fetch programs error:", error)
        }
    }

    func loadDayPrograms(context: ModelContext) {
        do {
            let assignments = try context.fetch(FetchDescriptor<ProgramAssignment>())
            dayPrograms = [:]
            for assign in assignments {
                let day = assign.date.startOfDay
                // Не показываем прошлые даты
                if day >= Date().startOfDay {
                    dayPrograms[day, default: []].append(assign.program)
                }
            }
        } catch {
            print("Fetch assignments error:", error)
        }
    }
}
