import Foundation
import SwiftData

struct SwiftDataChatMessageRepository: ChatMessageRepository {
    let context: ModelContext

    func fetchAll() throws -> [ChatMessage] {
        let descriptor = FetchDescriptor<ChatMessage>(sortBy: [SortDescriptor(\.createdAt)])
        return try context.fetch(descriptor)
    }

    func insert(role: ChatMessageRole, text: String) throws -> ChatMessage {
        let message = ChatMessage(role: role, text: text)
        context.insert(message)
        try context.save()
        return message
    }

    func deleteAll() throws {
        let descriptor = FetchDescriptor<ChatMessage>()
        let items = try context.fetch(descriptor)
        items.forEach { context.delete($0) }
        if context.hasChanges {
            try context.save()
        }
    }
}
