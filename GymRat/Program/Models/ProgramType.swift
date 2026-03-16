import Foundation

enum ProgramType: String, CaseIterable, Identifiable, Codable {
    case strength
    case cardio
    case crossfit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .strength: return String(localized: "program_type_strength")
        case .cardio: return String(localized: "program_type_cardio")
        case .crossfit: return String(localized: "program_type_crossfit")
        }
    }

    func allows(_ exercise: ExerciseModel) -> Bool {
        switch self {
        case .strength: return exercise.category == .strength
        case .cardio: return exercise.category == .cardio
        case .crossfit: return true
        }
    }

    func allows(_ category: ExerciseCategory) -> Bool {
        switch self {
        case .strength: return category == .strength
        case .cardio: return category == .cardio
        case .crossfit: return true
        }
    }
}
