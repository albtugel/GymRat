import Foundation

@MainActor
protocol TimelineServiceType {
    func fetchItems() async throws -> [Event]
    func insertItem(_ item: Event) async throws
    func deleteItem(_ item: Event) async throws
    func deleteAllItems() async throws
}
