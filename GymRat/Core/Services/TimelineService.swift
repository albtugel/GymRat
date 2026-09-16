import Foundation
import SwiftData

@MainActor
final class TimelineService: TimelineServiceType {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchItems() throws -> [Event] {
        let descriptor = FetchDescriptor<Event>(sortBy: [SortDescriptor(\.startDate)])
        return try modelContext.fetch(descriptor)
    }

    func insertItem(_ item: Event) throws {
        modelContext.insert(item)
        try modelContext.save()
    }

    func deleteItem(_ item: Event) throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func deleteAllItems() throws {
        let descriptor = FetchDescriptor<Event>()
        let items = try modelContext.fetch(descriptor)
        items.forEach { modelContext.delete($0) }
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
