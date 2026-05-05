import Foundation
import SwiftData

@Model
final class ScheduleItem: Identifiable {
    @Attribute(.unique) var id: UUID
    @Relationship(deleteRule: .cascade)
    var program: Program
    var date: Date

    init(id: UUID = UUID(), program: Program, date: Date) {
        self.id = id
        self.program = program
        self.date = date
    }
}
