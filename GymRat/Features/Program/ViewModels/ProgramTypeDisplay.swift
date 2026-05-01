import Foundation

enum ProgramTypeDisplay {
    static func title(for type: ProgramType) -> String {
        switch type {
        case .strength: return String(localized: "program_type_strength")
        case .cardio: return String(localized: "program_type_cardio")
        case .crossfit: return String(localized: "program_type_crossfit")
        }
    }

    static func allows(_ type: ProgramType, category: ExerciseCategory) -> Bool {
        switch type {
        case .strength: return category == .strength
        case .cardio: return category == .cardio
        case .crossfit: return true
        }
    }
}
