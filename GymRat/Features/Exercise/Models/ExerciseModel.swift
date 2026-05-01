import Foundation
import SwiftData

@Model
final class ExerciseModel: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var categoryRaw: String
    var isCustom: Bool = false

    init(id: UUID = UUID(), name: String, categoryRaw: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.categoryRaw = categoryRaw
        self.isCustom = isCustom
    }
}
