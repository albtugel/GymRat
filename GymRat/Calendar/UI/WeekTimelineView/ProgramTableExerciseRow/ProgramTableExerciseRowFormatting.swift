import Foundation

extension ProgramTableExerciseRowView {
    // MARK: - Formatting
    func parseWeight(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    func formatWeight(_ weight: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        return formatter.string(from: NSNumber(value: weight)) ?? String(weight)
    }

    // MARK: - Input Sanitizers
    func sanitizeDecimalInput(_ text: String, maxFractionDigits: Int) -> String {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        var result = ""
        var hasDot = false
        var fractionCount = 0

        for ch in normalized {
            if ch.isNumber {
                if hasDot {
                    if fractionCount < maxFractionDigits {
                        result.append(ch)
                        fractionCount += 1
                    }
                } else {
                    result.append(ch)
                }
            } else if ch == "." && !hasDot {
                hasDot = true
                result.append(ch)
            }
        }

        if result == "." { return "0." }
        return result
    }

    func sanitizeIntegerInput(_ text: String, allowDash: Bool) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if allowDash && trimmed == "-" { return "-" }
        return trimmed.filter { $0.isNumber }
    }
}
