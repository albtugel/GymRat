import Foundation
import SwiftData

@Model
final class ScheduleItem: Identifiable {
    @Attribute(.unique) var id: UUID
    // Optional so SwiftData can nil it out instead of leaving a dangling
    // reference; the owning side (Program.scheduleItems) cascades deletes.
    var program: Program?
    var date: Date

    init(id: UUID = UUID(), program: Program, date: Date) {
        self.id = id
        self.program = program
        self.date = date
    }
}
