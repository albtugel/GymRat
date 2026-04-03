import Foundation

enum WeightUnit: String, CaseIterable {
    case kg = "kg"
    case lbs = "lbs"

    var label: String {
        switch self {
        case .kg: return String(localized: "kg_label")
        case .lbs: return String(localized: "lbs_label")
        }
    }
}
