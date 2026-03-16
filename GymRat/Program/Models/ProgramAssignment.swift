import Foundation
import SwiftData

@Model
final class ProgramAssignment: Identifiable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade)
    var program: ProgramModel
    var date: Date

    init(program: ProgramModel, date: Date) {
        self.id = UUID()
        self.program = program
        self.date = date
    }
}
