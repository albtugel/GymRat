import Foundation

@MainActor
protocol TimelineServiceType {
    func fetchItems() throws -> [Event]
    func insertItem(_ item: Event) throws
    func deleteItem(_ item: Event) throws
    func deleteAllItems() throws
}
