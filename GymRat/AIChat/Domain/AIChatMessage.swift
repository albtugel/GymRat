import Foundation

enum AIChatRole: String, Codable {
    case user
    case assistant
}

struct AIChatMessage: Codable, Equatable {
    let role: AIChatRole
    let text: String
}
