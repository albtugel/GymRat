import Foundation
import SwiftData

@Model
final class ProgramModel: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var typeRaw: String
    @Relationship(deleteRule: .cascade)
    var exercises: [ProgramExercise] = []
    @Attribute var colorHex: String? = nil

    @Attribute var weekdaysRaw: [String] = []

    init(
        id: UUID = UUID(),
        name: String,
        typeRaw: String,
        exercises: [ProgramExercise] = [],
        colorHex: String? = nil,
        weekdaysRaw: [String] = []
    ) {
        self.id = id
        self.name = name
        self.typeRaw = typeRaw
        self.exercises = exercises
        self.colorHex = colorHex
        self.weekdaysRaw = weekdaysRaw
    }
}
