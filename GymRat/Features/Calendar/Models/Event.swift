import Foundation
import SwiftData

@Model
final class Event {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var startDate: Date
    var endDate: Date
    var typeRaw: String
    var program: Program?

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        typeRaw: String,
        program: Program? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.typeRaw = typeRaw
        self.program = program
    }
}
