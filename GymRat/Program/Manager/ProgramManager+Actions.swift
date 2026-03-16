import Foundation
import SwiftData

extension ProgramManager {
    // MARK: Add program and create assignments
    func addProgram(_ program: ProgramModel, context: ModelContext) {
        context.insert(program)
        customPrograms.append(program)

        let calendar = AppCalendar.calendar
        let today = Date()
        let startOfWeek = today.startOfWeek

        for weekday in program.weekdays {
            if let targetDate = calendar.nextDate(after: startOfWeek.addingTimeInterval(-1),
                                                 matching: DateComponents(weekday: weekday.systemWeekdayNumber),
                                                 matchingPolicy: .nextTime) {
                let assignment = ProgramAssignment(program: program, date: targetDate)
                context.insert(assignment)

                let day = targetDate.startOfDay
                dayPrograms[day, default: []].append(program)
            }
        }

        if context.hasChanges {
            try? context.save()
        }
    }

    // MARK: Delete program and related assignments
    func deleteProgram(_ program: ProgramModel, context: ModelContext) {
        context.delete(program)
        programs.removeAll { $0.id == program.id }
        customPrograms.removeAll { $0.id == program.id }

        do {
            let assignments = try context.fetch(FetchDescriptor<ProgramAssignment>())
            for assign in assignments where assign.program.id == program.id {
                context.delete(assign)
            }
        } catch {
            print("Delete assignments error:", error)
        }

        // Обновляем dayPrograms
        for key in dayPrograms.keys {
            dayPrograms[key]?.removeAll { $0.id == program.id }
        }

        if context.hasChanges {
            try? context.save()
        }
    }
}
