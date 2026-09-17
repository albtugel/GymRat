import Foundation
import Testing
@testable import GymRat

struct ExerciseEntryFormatterTests {

    @Test(arguments: [
        (WeightUnit.kg, 60.0, "60"),
        (WeightUnit.kg, 62.5, "62.5"),
        (WeightUnit.lbs, 60.0, "132.28"),
        (WeightUnit.kg, 0.0, "")
    ])
    func weightIsShownInTheUsersUnit(unit: WeightUnit, stored: Double, expected: String) {
        let formatter = Self.makeFormatter(weight: unit)
        #expect(formatter.weightText(stored) == expected)
    }

    @Test(arguments: [
        (WeightUnit.kg, "62,5", 62.5),
        (WeightUnit.lbs, "132.28", 60.0),
        (WeightUnit.kg, "", 0.0)
    ])
    func typedWeightIsStoredInKilograms(unit: WeightUnit, typed: String, expected: Double) {
        let formatter = Self.makeFormatter(weight: unit)
        #expect(abs(formatter.weight(from: typed) - expected) < 0.01)
    }

    @Test func cardioDistanceRoundTripsThroughTheDistanceUnit() {
        let kilometers = Self.makeFormatter(distance: .kilometers, isCardio: true)
        #expect(kilometers.repsText(2500) == "2.50")
        #expect(kilometers.reps(from: "2.5") == 2500)

        let miles = Self.makeFormatter(distance: .miles, isCardio: true)
        #expect(miles.reps(from: "1") == 1609)
        #expect(miles.repsText(1609) == "1.00")
    }

    @Test func durationUsesMinutesAndSeconds() {
        let formatter = Self.makeFormatter()
        #expect(formatter.durationText(125) == "2:05")
        #expect(formatter.durationText(0) == "")
        #expect(formatter.duration(from: "2:05") == 125)
        #expect(formatter.duration(from: "90") == 90)
    }

    @Test func typedInputIsCleaned() {
        let strength = Self.makeFormatter()
        #expect(strength.sanitizedReps(" 1a2 ") == "12")
        #expect(strength.sanitizedWeight("62,555") == "62.55")
        #expect(strength.sanitizedWeight(".") == "0.")
        #expect(strength.sanitizedDuration("12:345") == "12:34")
        #expect(strength.sanitizedDuration("1234") == "12")

        let cardio = Self.makeFormatter(isCardio: true)
        #expect(cardio.sanitizedWeight("12.5") == "125")
    }

    @Test func setCountIsClamped() {
        #expect(ExerciseEntryFormatter.clampedSets(0) == 1)
        #expect(ExerciseEntryFormatter.clampedSets(42) == ExerciseEntryFormatter.maxSets)
        #expect(ExerciseEntryFormatter.digits("1x2") == "12")
    }

    private static func makeFormatter(
        weight: WeightUnit = .kg,
        distance: DistanceUnit = .kilometers,
        isCardio: Bool = false
    ) -> ExerciseEntryFormatter {
        let defaults = UserDefaults(suiteName: "ExerciseEntryFormatterTests-\(UUID().uuidString)") ?? .standard
        let units = Units(defaults: defaults)
        units.weightUnit = weight.rawValue
        units.distanceUnit = distance.rawValue
        return ExerciseEntryFormatter(units: units, isCardio: isCardio)
    }
}
