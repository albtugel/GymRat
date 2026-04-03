import Foundation
import SwiftData

@Model
final class TimelineItem {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var startDate: Date
    var endDate: Date
    var typeRaw: String
    var program: ProgramModel?

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        typeRaw: String,
        program: ProgramModel? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.typeRaw = typeRaw
        self.program = program
    }
}
