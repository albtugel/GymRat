import SwiftUI
import SwiftData

extension ProgramTableExerciseRowView {
    // MARK: - Save
    func saveCurrentLogIfNeeded() {
        guard isDirty || setsEditedForDay else { return }
        guard let targetDate = editSessionDate else { return }
        saveCurrentLog(for: targetDate)
    }

    func saveCurrentLog(for date: Date) {
        normalizeArrays()

        let reps = repsBySetText.map { text -> Int in
            let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if isCardio {
                let value = Double(t) ?? 0
                return unitsManager.storeDistance(value)
            }
            return Int(t) ?? 0
        }
        let weights = weightsBySetText.map { text -> Double in
            let value = parseWeight(text) ?? 0
            return isCardio ? value : unitsManager.storeWeight(value)
        }
        let durations = durationsBySetText.map { text -> Int in
            let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let parts = t.split(separator: ":")
            if parts.count == 2, let mins = Int(parts[0]), let secs = Int(parts[1]) {
                return mins * 60 + secs
            }
            return Int(t) ?? 0
        }
        let hasValues = reps.contains { $0 > 0 } || weights.contains { $0 > 0 } || durations.contains { $0 > 0 }
        let day = date.startOfDay
        let dayStamp = ProgramExerciseLog.makeDayStamp(for: day)
        let logForDay = fetchLog(for: dayStamp)
        if let log = logForDay {
            if hasValues || setsEditedForDay {
                log.date = day
                log.dayStamp = dayStamp
                log.programExercise = programExercise
                log.exerciseName = programExercise.exercise.name
                log.repsBySet = reps
                log.weightsBySet = weights
                log.durationsBySet = durations
            } else {
                context.delete(log)
            }
        } else if hasValues || setsEditedForDay {
            let newLog = ProgramExerciseLog(
                programExercise: programExercise,
                date: day,
                repsBySet: reps,
                weightsBySet: weights,
                durationsBySet: durations
            )
            context.insert(newLog)
        }

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("ProgramExerciseLog save error:", error)
            }
        }
        let dataStamp = ProgramExerciseLog.makeDayStamp(for: dataDate)
        if let saved = logForDay, saved.dayStamp == dataStamp {
            currentLog = saved
        } else if dataStamp == dayStamp {
            currentLog = fetchLog(for: dayStamp)
        }
        isDirty = false
        setsEditedForDay = false
        editSessionDate = nil
    }

    // MARK: - Normalization
    func normalizeArrays() {
        repsBySetText = normalize(repsBySetText, fill: "")
        weightsBySetText = normalize(weightsBySetText, fill: "")
        durationsBySetText = normalize(durationsBySetText, fill: "")
        previousRepsBySetText = normalize(previousRepsBySetText, fill: "")
        previousWeightsBySetText = normalize(previousWeightsBySetText, fill: "")
        previousDurationsBySetText = normalize(previousDurationsBySetText, fill: "")
    }

    func normalize(_ array: [String], fill: String) -> [String] {
        var result = array
        if result.count < setsCount {
            result.append(contentsOf: Array(repeating: fill, count: setsCount - result.count))
        } else if result.count > setsCount {
            result = Array(result.prefix(setsCount))
        }
        return result
    }
}
