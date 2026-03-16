import Foundation

enum ExerciseIntensity: String, CaseIterable, Identifiable, Codable {
    case strength
    case cardio

    var id: String { rawValue }
}
