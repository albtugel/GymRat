import Foundation

enum ExerciseField: Hashable {
    case sets(UUID)
    case reps(UUID, Int)
    case weight(UUID, Int)
    case duration(UUID, Int)
}
