import Foundation

struct AIChatRequest: Codable, Equatable {
    let messages: [AIChatMessage]
    let context: AIChatContext
}

struct AIChatResponse: Codable, Equatable {
    let text: String
    let programChangeRequest: ProgramChangeRequest?
}
