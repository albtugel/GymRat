import SwiftData
import Foundation

@Model
final class DayProgram: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date

    @Relationship(deleteRule: .nullify)
    var program: Program

    init(id: UUID = UUID(), date: Date, program: Program) {
        self.id = id
        self.date = date
        self.program = program
    }
}
