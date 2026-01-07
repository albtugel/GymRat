import Foundation
import SwiftData

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var items: [TimelineItem] = []

    var context: ModelContext? // ← теперь context опциональный

    // init без аргументов
    init() {}

    func loadItems() {
        guard let context else { return }
        do {
            items = try context.fetch(FetchDescriptor<TimelineItem>(sortBy: [SortDescriptor(\.startDate)]))
        } catch {
            items = []
        }
    }

    func addWorkout(title: String, date: Date) {
        guard let context else { return }
        let session = WorkoutSession(date: date)
        let item = TimelineItem(
            title: title,
            startDate: date,
            endDate: date.addingTimeInterval(3600),
            type: .workout,
            workoutSession: session
        )
        context.insert(session)
        context.insert(item)
        items.append(item)
    }

    func addPersonalEvent(title: String, startDate: Date, endDate: Date) {
        guard let context else { return }
        let item = TimelineItem(title: title, startDate: startDate, endDate: endDate, type: .personal)
        context.insert(item)
        items.append(item)
    }
}
