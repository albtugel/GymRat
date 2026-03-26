import Foundation
import SwiftData

enum ExerciseCategory: String, CaseIterable, Identifiable, Codable {
    case strength
    case cardio
    case crossfit

    var id: String { rawValue }

    var localizedLabel: String {
        switch self {
        case .strength: return String(localized: "program_type_strength")
        case .cardio: return String(localized: "program_type_cardio")
        case .crossfit: return String(localized: "program_type_crossfit")
        }
    }
}

@Model
final class ExerciseModel: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var categoryRaw: String
    var isCustom: Bool = false

    var category: ExerciseCategory {
        get { ExerciseCategory(rawValue: categoryRaw) ?? .strength }
        set { categoryRaw = newValue.rawValue }
    }

    init(name: String, category: ExerciseCategory, isCustom: Bool = false) {
        self.name = name
        self.categoryRaw = category.rawValue  
        self.isCustom = isCustom
    }
}
