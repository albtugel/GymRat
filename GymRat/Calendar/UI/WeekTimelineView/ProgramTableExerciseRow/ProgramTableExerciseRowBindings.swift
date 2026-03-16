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
            get: { index < durationsBySetText.count ? durationsBySetText[index] : "" },
            set: { newValue in
                let sanitized = sanitizeIntegerInput(newValue, allowDash: false)
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
