import SwiftUI

extension ProgramTableExerciseRowView {
    // MARK: - Bindings
    var setsCountBinding: Binding<String> {
        Binding(
            get: { setsCountText },
            set: { newValue in
                let sanitized = sanitizeIntegerInput(newValue, allowDash: false)
                if sanitized.isEmpty {
                    setsCountText = ""
                    return
                }

                if let value = Int(sanitized) {
                    setsCountText = String(min(10, max(1, value)))
                } else {
                    return
                }
                programExercise.sets = setsCount
                setsEditedForDay = true
                isDirty = true
                if editSessionDate == nil {
                    editSessionDate = dataDate
                }
                normalizeArrays()
            }
        )
    }

    func repsBinding(index: Int) -> Binding<String> {
        Binding(
            get: { index < repsBySetText.count ? repsBySetText[index] : "" },
            set: { newValue in
                let sanitized = sanitizeIntegerInput(newValue, allowDash: false)
                if index < repsBySetText.count {
                    repsBySetText[index] = sanitized
                }
                isDirty = true
                if editSessionDate == nil {
                    editSessionDate = dataDate
                }
            }
        )
    }

    func weightBinding(index: Int) -> Binding<String> {
        Binding(
            get: { index < weightsBySetText.count ? weightsBySetText[index] : "" },
            set: { newValue in
                let sanitized = isCardio
                    ? sanitizeIntegerInput(newValue, allowDash: false)
                    : sanitizeDecimalInput(newValue, maxFractionDigits: 2)
                if index < weightsBySetText.count {
                    weightsBySetText[index] = sanitized
                }
                isDirty = true
                if editSessionDate == nil {
                    editSessionDate = dataDate
                }
            }
        )
    }

    func durationBinding(index: Int) -> Binding<String> {
        Binding(
            get: {
                guard index < durationsBySetText.count else { return "" }
                let raw = durationsBySetText[index]
          
                if raw.contains(":") { return raw }
      
                if let totalSeconds = Int(raw), !raw.isEmpty {
                    let mins = totalSeconds / 60
                    let secs = totalSeconds % 60
                    return String(format: "%d:%02d", mins, secs)
                }
                return raw
            },
            set: { newValue in
                var sanitized = newValue
                    .filter { $0.isNumber || $0 == ":" }
                
       
                let parts = sanitized.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    let mins = String(parts[0].prefix(2))
                    let secs = String(parts[1].prefix(2))
                    sanitized = "\(mins):\(secs)"
                } else {
                    sanitized = String(sanitized.prefix(2))
                }
                
                if index < durationsBySetText.count {
                    durationsBySetText[index] = sanitized
                }
                isDirty = true
                if editSessionDate == nil {
                    editSessionDate = dataDate
                }
            }
        )
    }
}
