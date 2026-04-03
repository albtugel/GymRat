import SwiftData
import Foundation

@Model
final class DayProgramModel: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date

    @Relationship(deleteRule: .nullify)
    var program: ProgramModel

    init(id: UUID = UUID(), date: Date, program: ProgramModel) {
        self.id = id
        self.date = date
        self.program = program
    }
}
