import Foundation
import SwiftData

@MainActor
final class TimelineItemService: TimelineItemServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchItems() async throws -> [TimelineItem] {
        let descriptor = FetchDescriptor<TimelineItem>(sortBy: [SortDescriptor(\.startDate)])
        return try modelContext.fetch(descriptor)
    }

    func insertItem(_ item: TimelineItem) async throws {
        modelContext.insert(item)
        try modelContext.save()
    }

    func deleteItem(_ item: TimelineItem) async throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func deleteAllItems() async throws {
        let descriptor = FetchDescriptor<TimelineItem>()
        let items = try modelContext.fetch(descriptor)
        items.forEach { modelContext.delete($0) }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
