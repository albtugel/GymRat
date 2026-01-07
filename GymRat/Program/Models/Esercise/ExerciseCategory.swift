import Foundation

enum ExerciseCategory: String, CaseIterable, Identifiable {
    case upperBody
    case lowerBody
    case fullBody
    case cardio
    case crossfit

    var id: String { rawValue }
}

