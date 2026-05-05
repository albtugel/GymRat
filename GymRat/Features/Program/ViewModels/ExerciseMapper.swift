import Foundation

enum ExerciseMapper {
    static func category(for exercise: Exercise) -> ExerciseCategory {
        ExerciseCategory(rawValue: exercise.categoryRaw) ?? .strength
    }

    static func setCategory(_ category: ExerciseCategory, for exercise: Exercise) {
        exercise.categoryRaw = category.rawValue
    }
}
