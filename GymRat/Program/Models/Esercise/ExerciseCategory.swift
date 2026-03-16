import Foundation
import SwiftData

enum ExerciseCategory: String, CaseIterable, Identifiable, Codable {
    case strength
    case cardio
    case crossfit

    var id: String { rawValue }
}

@Model
final class ExerciseModel: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var category: ExerciseCategory

    init(name: String, category: ExerciseCategory) {
        self.name = name
        self.category = category
    }
}
