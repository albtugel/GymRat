import Foundation

enum ExerciseModelMapper {
    static func category(for exercise: ExerciseModel) -> ExerciseCategory {
        ExerciseCategory(rawValue: exercise.categoryRaw) ?? .strength
    }

    static func setCategory(_ category: ExerciseCategory, for exercise: ExerciseModel) {
        exercise.categoryRaw = category.rawValue
    }
}
