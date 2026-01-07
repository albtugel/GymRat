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
            let currentCount = max(log.repsBySet.count, log.weightsBySet.count)
            setsCountText = String(max(1, currentCount))
        } else if let prev = previousLog {
            let prevCount = max(prev.repsBySet.count, prev.weightsBySet.count)
            setsCountText = String(max(1, prevCount))
        } else {
            setsCountText = String(max(1, programExercise.sets))
        }
        setsEditedForDay = false

        if let log = currentLog {
            repsBySetText = log.repsBySet.map { $0 == 0 ? "" : String($0) }
            weightsBySetText = log.weightsBySet.map { $0 == 0 ? "" : formatWeight($0) }
        } else {
            repsBySetText = Array(repeating: "", count: setsCount)
            weightsBySetText = Array(repeating: "", count: setsCount)
        }

        if let log = previousLog {
            previousRepsBySetText = log.repsBySet.map { $0 == 0 ? "" : String($0) }
            previousWeightsBySetText = log.weightsBySet.map { $0 == 0 ? "" : formatWeight($0) }
        } else {
            previousRepsBySetText = Array(repeating: "", count: setsCount)
            previousWeightsBySetText = Array(repeating: "", count: setsCount)
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
