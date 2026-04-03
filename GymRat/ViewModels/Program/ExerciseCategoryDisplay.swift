import Foundation

enum ExerciseCategoryDisplay {
    static func localizedLabel(for category: ExerciseCategory) -> String {
        switch category {
        case .strength: return String(localized: "program_type_strength")
        case .cardio: return String(localized: "program_type_cardio")
        case .crossfit: return String(localized: "program_type_crossfit")
        }
    }
}
