import Foundation

enum DistanceUnit: String, CaseIterable {
    case kilometers = "km"
    case miles = "mi"

    var label: String {
        switch self {
        case .kilometers: return String(localized: "kilometers_label")
        case .miles: return String(localized: "miles_label")
        }
    }
}
