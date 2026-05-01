import Foundation
import SwiftData

@Model
final class ProgramAssignment: Identifiable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade)
    var program: ProgramModel
    var date: Date

    init(id: UUID = UUID(), program: ProgramModel, date: Date) {
        self.id = id
        self.program = program
        self.date = date
    }
}
