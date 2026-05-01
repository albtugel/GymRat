import Foundation

enum ProgramModelMapper {
    static func type(for program: ProgramModel) -> ProgramType {
        ProgramType(rawValue: program.typeRaw) ?? .strength
    }

    static func setType(_ type: ProgramType, for program: ProgramModel) {
        program.typeRaw = type.rawValue
    }

    static func weekdays(for program: ProgramModel) -> Set<ProgramWeekDay> {
        Set(program.weekdaysRaw.compactMap { ProgramWeekDay(rawValue: $0) })
    }

    static func setWeekdays(_ weekdays: Set<ProgramWeekDay>, for program: ProgramModel) {
        program.weekdaysRaw = weekdays.map { $0.rawValue }
    }
}
