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

    var type: ProgramType {
        get { ProgramType(rawValue: typeRaw) ?? .strength }
        set { typeRaw = newValue.rawValue }
    }

    var weekdays: Set<ProgramWeekDay> {
        get { Set(weekdaysRaw.compactMap { ProgramWeekDay(rawValue: $0) }) }
        set { weekdaysRaw = newValue.map { $0.rawValue } }
    }

    init(name: String, type: ProgramType = .strength, exercises: [ProgramExercise] = []) {
        self.id = UUID()
        self.name = name
        self.typeRaw = type.rawValue
        self.exercises = exercises
    }
}
