import Foundation

@MainActor
protocol TimelineItemServiceProtocol {
    func fetchItems() async throws -> [TimelineItem]
    func insertItem(_ item: TimelineItem) async throws
    func deleteItem(_ item: TimelineItem) async throws
    func deleteAllItems() async throws
}
