import Foundation

enum ProgramTableFocusField: Hashable {
    case sets(UUID)
    case reps(UUID, Int)
    case weight(UUID, Int)
    case duration(UUID, Int)
}
