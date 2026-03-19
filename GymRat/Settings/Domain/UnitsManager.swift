import SwiftUI

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

class UnitsManager: ObservableObject {
    static let shared = UnitsManager()
    
    @AppStorage("weightUnit") var weightUnit: String = WeightUnit.kg.rawValue
    @AppStorage("distanceUnit") var distanceUnit: String = DistanceUnit.kilometers.rawValue
    
    var currentWeightUnit: WeightUnit {
        WeightUnit(rawValue: weightUnit) ?? .kg
    }
    
    var currentDistanceUnit: DistanceUnit {
        DistanceUnit(rawValue: distanceUnit) ?? .kilometers
    }
    
    // MARK: - Weight conversion
    func displayWeight(_ kg: Double) -> Double {
        switch currentWeightUnit {
        case .kg: return kg
        case .lbs: return kg * 2.20462
        }
    }
    
    func storeWeight(_ value: Double) -> Double {
        switch currentWeightUnit {
        case .kg: return value
        case .lbs: return value / 2.20462
        }
    }
    
    // MARK: - Distance conversion
    func displayDistance(_ meters: Int) -> Double {
        switch currentDistanceUnit {
        case .kilometers: return Double(meters) / 1000.0
        case .miles: return Double(meters) / 1609.344
        }
    }
    
    func storeDistance(_ value: Double) -> Int {
        switch currentDistanceUnit {
        case .kilometers: return Int(value * 1000.0)
        case .miles: return Int(value * 1609.344)
        }
    }
}
