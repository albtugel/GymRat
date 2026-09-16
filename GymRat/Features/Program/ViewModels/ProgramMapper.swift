import Foundation

enum ProgramMapper {
    static func type(for program: Program) -> ProgramType {
        ProgramType(rawValue: program.typeRaw) ?? .strength
    }

    static func weekdays(for program: Program) -> Set<ProgramWeekday> {
        Set(program.weekdaysRaw.compactMap { ProgramWeekday(rawValue: $0) })
    }

    static func setWeekdays(_ weekdays: Set<ProgramWeekday>, for program: Program) {
        program.weekdaysRaw = weekdays.map { $0.rawValue }
    }
}
