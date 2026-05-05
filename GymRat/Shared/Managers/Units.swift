import Foundation
import Observation

@Observable
final class Units {
    private enum Keys {
        static let weightUnit = "weightUnit"
        static let distanceUnit = "distanceUnit"
    }

    private let defaults: UserDefaults

    var weightUnit: String {
        didSet { defaults.set(weightUnit, forKey: Keys.weightUnit) }
    }

    var distanceUnit: String {
        didSet { defaults.set(distanceUnit, forKey: Keys.distanceUnit) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        weightUnit = defaults.string(forKey: Keys.weightUnit) ?? WeightUnit.kg.rawValue
        distanceUnit = defaults.string(forKey: Keys.distanceUnit) ?? DistanceUnit.kilometers.rawValue
    }

    var currentWeightUnit: WeightUnit {
        WeightUnit(rawValue: weightUnit) ?? .kg
    }

    var currentDistanceUnit: DistanceUnit {
        DistanceUnit(rawValue: distanceUnit) ?? .kilometers
    }

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
