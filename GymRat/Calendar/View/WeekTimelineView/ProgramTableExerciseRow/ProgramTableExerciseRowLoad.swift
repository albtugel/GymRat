import SwiftUI
import SwiftData

extension ProgramTableExerciseRowView {
    // MARK: - Data Loading
    func loadLog() {
        isLoadingLog = true
        let day = selectedDate.startOfDay
        let dayStamp = ProgramExerciseLog.makeDayStamp(for: day)
        let logs = fetchAllLogs().filter { matchesExercise($0) }
        normalizeLogDatesIfNeeded(logs)

        let sameDayLogs = logs.filter { $0.dayStamp == dayStamp }
        if sameDayLogs.count > 1 {
            let sorted = sameDayLogs.sorted { logScore($0) > logScore($1) }
            currentLog = sorted.first
            for log in sorted.dropFirst() {
                context.delete(log)
            }
            if context.hasChanges {
                try? context.save()
            }
        } else {
            currentLog = sameDayLogs.first
        }

        let previousLog = logs
            .filter { $0.dayStamp < dayStamp && hasValues($0) }
            .sorted { $0.dayStamp > $1.dayStamp }
            .first

        if let log = currentLog {
            let currentCount = max(log.repsBySet.count, max(log.weightsBySet.count, log.durationsBySet.count))
            setsCountText = String(max(1, currentCount))
        } else if let prev = previousLog {
            let prevCount = max(prev.repsBySet.count, max(prev.weightsBySet.count, prev.durationsBySet.count))
            setsCountText = String(max(1, prevCount))
        } else {
            setsCountText = String(max(1, programExercise.sets))
        }
        setsEditedForDay = false

        if let log = currentLog {
            repsBySetText = log.repsBySet.map { value -> String in
                guard value > 0 else { return "" }
                if isCardio {
                    let displayed = unitsManager.displayDistance(value)
                    return displayed.truncatingRemainder(dividingBy: 1) == 0
                        ? String(Int(displayed))
                        : String(format: "%.2f", displayed)
                }
                return String(value)
            }
            weightsBySetText = log.weightsBySet.map { value -> String in
                guard value > 0 else { return "" }
                return isCardio ? formatWeight(value) : formatWeight(unitsManager.displayWeight(value))
            }
            durationsBySetText = log.durationsBySet.map { seconds in
                guard seconds > 0 else { return "" }
                let mins = seconds / 60
                let secs = seconds % 60
                return String(format: "%d:%02d", mins, secs)
            }
        } else {
            repsBySetText = Array(repeating: "", count: setsCount)
            weightsBySetText = Array(repeating: "", count: setsCount)
            durationsBySetText = Array(repeating: "", count: setsCount)
        }

        if let log = previousLog {
            previousRepsBySetText = log.repsBySet.map { value -> String in
                guard value > 0 else { return "" }
                if isCardio {
                    let displayed = unitsManager.displayDistance(value)
                    return displayed.truncatingRemainder(dividingBy: 1) == 0
                        ? String(Int(displayed))
                        : String(format: "%.2f", displayed)
                }
                return String(value)
            }
            previousWeightsBySetText = log.weightsBySet.map { value -> String in
                guard value > 0 else { return "" }
                return isCardio ? formatWeight(value) : formatWeight(unitsManager.displayWeight(value))
            }
            previousDurationsBySetText = log.durationsBySet.map { seconds in
                guard seconds > 0 else { return "" }
                let mins = seconds / 60
                let secs = seconds % 60
                return String(format: "%d:%02d", mins, secs)
            }
        } else {
            previousRepsBySetText = Array(repeating: "", count: setsCount)
            previousWeightsBySetText = Array(repeating: "", count: setsCount)
            previousDurationsBySetText = Array(repeating: "", count: setsCount)
        }

        normalizeArrays()
        dataDate = day
        editSessionDate = nil
        isDirty = false
        isLoadingLog = false
    }

    func fetchAllLogs() -> [ProgramExerciseLog] {
        (try? context.fetch(FetchDescriptor<ProgramExerciseLog>())) ?? []
    }

    func normalizeLogDatesIfNeeded(_ logs: [ProgramExerciseLog]) {
        var didChange = false
        for log in logs {
            let normalized = AppCalendar.calendar.startOfDay(for: log.date)
            let stamp = ProgramExerciseLog.makeDayStamp(for: normalized)
            if log.date != normalized {
                log.date = normalized
                didChange = true
            }
            if log.dayStamp != stamp {
                log.dayStamp = stamp
                didChange = true
            }
        }
        if didChange, context.hasChanges {
            try? context.save()
        }
    }
}
