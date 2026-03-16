import Foundation

extension ProgramWeekDay {
    init?(calendarNumber: Int) {
        switch calendarNumber {
        case 1: self = .monday
        case 2: self = .tuesday
        case 3: self = .wednesday
        case 4: self = .thursday
        case 5: self = .friday
        case 6: self = .saturday
        case 7: self = .sunday
        default: return nil
        }
    }
}
