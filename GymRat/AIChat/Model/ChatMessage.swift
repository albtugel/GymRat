import Foundation
import SwiftData

enum ChatMessageRole: String, Codable {
    case user
    case assistant
}

@Model
final class ChatMessage: Identifiable {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var role: String
    var text: String

    init(role: ChatMessageRole, text: String, createdAt: Date = Date()) {
        self.id = UUID()
        self.createdAt = createdAt
        self.role = role.rawValue
        self.text = text
    }

    var isUser: Bool {
        role == ChatMessageRole.user.rawValue
    }
}
