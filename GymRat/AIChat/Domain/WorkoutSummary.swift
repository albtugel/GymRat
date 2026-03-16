import Foundation

struct WorkoutSummary: Codable, Equatable {
    let totalLogs: Int
    let dateStart: Date?
    let dateEnd: Date?
    let exercises: [ExerciseSummary]
}

struct ExerciseSummary: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let totalLogs: Int
    let totalSets: Int
    let totalReps: Int
    let totalVolume: Double
    let lastReps: Int?
    let lastWeight: Double?
    let lastDate: Date?
}
