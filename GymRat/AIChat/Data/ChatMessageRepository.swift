import Foundation

protocol ChatMessageRepository {
    func fetchAll() throws -> [ChatMessage]
    func insert(role: ChatMessageRole, text: String) throws -> ChatMessage
    func deleteAll() throws
}
