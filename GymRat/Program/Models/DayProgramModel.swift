import SwiftData
import Foundation

@Model
final class DayProgramModel: Identifiable {
    @Attribute(.unique) var id: UUID
    var date: Date

    @Relationship(deleteRule: .nullify)
    var program: ProgramModel

    init(date: Date, program: ProgramModel) {
        self.id = UUID()
        self.date = AppCalendar.calendar.startOfDay(for: date)
        self.program = program
    }
}
