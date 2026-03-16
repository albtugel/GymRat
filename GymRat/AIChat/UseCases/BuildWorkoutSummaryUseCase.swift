import Foundation

struct BuildWorkoutSummaryUseCase {
    let repository: WorkoutLogRepository

    func execute() -> WorkoutSummary {
        let logs = (try? repository.fetchAllLogs()) ?? []
        guard !logs.isEmpty else {
            return WorkoutSummary(totalLogs: 0, dateStart: nil, dateEnd: nil, exercises: [])
        }

        let sortedByDate = logs.sorted { $0.date < $1.date }
        let dateStart = sortedByDate.first?.date
        let dateEnd = sortedByDate.last?.date

        var grouped: [String: [ProgramExerciseLog]] = [:]
        for log in logs {
            let name = log.exerciseName ?? log.exercise.name
            grouped[name, default: []].append(log)
        }

        let exercises: [ExerciseSummary] = grouped.map { key, items in
            let sorted = items.sorted { $0.date < $1.date }
            let totalLogs = items.count
            let totalSets = items.reduce(0) {
                let count = max($1.repsBySet.count, max($1.weightsBySet.count, $1.durationsBySet.count))
                return $0 + count
            }
            let totalReps = items.reduce(0) { $0 + $1.repsBySet.reduce(0, +) }
            let totalVolume = items.reduce(0.0) { partial, log in
                let reps = log.repsBySet
                let weights = log.weightsBySet
                let count = max(reps.count, weights.count)
                var volume = 0.0
                for idx in 0..<count {
                    let r = idx < reps.count ? reps[idx] : 0
                    let w = idx < weights.count ? weights[idx] : 0
                    volume += Double(r) * w
                }
                return partial + volume
            }
            let last = sorted.last
            let lastReps = last?.repsBySet.last
            let lastWeight = last?.weightsBySet.last

            return ExerciseSummary(
                id: key,
                name: key,
                totalLogs: totalLogs,
                totalSets: totalSets,
                totalReps: totalReps,
                totalVolume: totalVolume,
                lastReps: lastReps,
                lastWeight: lastWeight,
                lastDate: last?.date
            )
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        return WorkoutSummary(
            totalLogs: logs.count,
            dateStart: dateStart,
            dateEnd: dateEnd,
            exercises: exercises
        )
    }
}
