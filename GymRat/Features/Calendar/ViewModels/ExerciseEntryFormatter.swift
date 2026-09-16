import Foundation

/// Converts between stored set values (kg, metres, seconds) and the text in a row's fields, in the
/// user's units, and cleans what the user types. Pure functions over `Units`, so each conversion can
/// be tested as a table.
struct ExerciseEntryFormatter {
    /// Text for the three columns of every set.
    struct SetTexts: Equatable {
        var reps: [String]
        var weights: [String]
        var durations: [String]
    }

    static let maxSets = 10
    static let weightFractionDigits = 2

    let units: Units
    /// Cardio rows store distance in the reps column and never convert weight.
    let isCardio: Bool

    // MARK: - Stored value → field text

    func repsText(_ value: Int) -> String {
        guard value > 0 else { return "" }
        if isCardio {
            let displayed = units.displayDistance(value)
            return displayed.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(displayed))
                : String(format: "%.2f", displayed)
        }
        return String(value)
    }

    func weightText(_ value: Double) -> String {
        guard value > 0 else { return "" }
        return Self.decimalText(isCardio ? value : units.displayWeight(value))
    }

    func durationText(_ seconds: Int) -> String {
        guard seconds > 0 else { return "" }
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    func texts(for values: ExerciseLogValues) -> SetTexts {
        SetTexts(
            reps: values.repsBySet.map(repsText),
            weights: values.weightsBySet.map(weightText),
            durations: values.durationsBySet.map(durationText)
        )
    }

    // MARK: - Field text → stored value

    func reps(from text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if isCardio {
            return units.storeDistance(Double(trimmed) ?? 0)
        }
        return Int(trimmed) ?? 0
    }

    func weight(from text: String) -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = Double(trimmed.replacingOccurrences(of: ",", with: ".")) ?? 0
        return isCardio ? value : units.storeWeight(value)
    }

    func duration(from text: String) -> Int {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: ":")
        if parts.count == 2, let minutes = Int(parts[0]), let seconds = Int(parts[1]) {
            return minutes * 60 + seconds
        }
        return Int(trimmed) ?? 0
    }

    func values(from texts: SetTexts) -> ExerciseLogValues {
        ExerciseLogValues(
            repsBySet: texts.reps.map(reps(from:)),
            weightsBySet: texts.weights.map(weight(from:)),
            durationsBySet: texts.durations.map(duration(from:))
        )
    }

    // MARK: - Cleaning typed input

    /// Digits only; a cardio row takes a decimal distance instead.
    func sanitizedReps(_ text: String) -> String {
        Self.digits(text)
    }

    func sanitizedWeight(_ text: String) -> String {
        isCardio ? Self.digits(text) : Self.decimal(text, maxFractionDigits: Self.weightFractionDigits)
    }

    /// Up to two digits of minutes and two of seconds, keeping one colon.
    func sanitizedDuration(_ text: String) -> String {
        let filtered = text.filter { $0.isNumber || $0 == ":" }
        let parts = filtered.split(separator: ":", maxSplits: 1)
        if parts.count == 2 {
            return "\(parts[0].prefix(2)):\(parts[1].prefix(2))"
        }
        return String(filtered.prefix(2))
    }

    static func clampedSets(_ value: Int) -> Int {
        min(maxSets, max(1, value))
    }

    static func digits(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).filter { $0.isNumber }
    }

    // MARK: - Helpers

    private static func decimal(_ text: String, maxFractionDigits: Int) -> String {
        var result = ""
        var hasDot = false
        var fractionCount = 0
        for character in text.replacingOccurrences(of: ",", with: ".") {
            if character.isNumber {
                if hasDot {
                    if fractionCount < maxFractionDigits {
                        result.append(character)
                        fractionCount += 1
                    }
                } else {
                    result.append(character)
                }
            } else if character == ".", !hasDot {
                hasDot = true
                result.append(character)
            }
        }
        return result == "." ? "0." : result
    }

    private static func decimalText(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = weightFractionDigits
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
}
