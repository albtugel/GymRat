//
//  TimelineViewModel.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import Foundation
import SwiftData

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var items: [TimelineItem] = []

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        loadItems()
    }

    func loadItems() {
        do {
            items = try context.fetch(FetchDescriptor<TimelineItem>(sortBy: [SortDescriptor(\.startDate)]))
        } catch {
            items = []
        }
    }

    func addWorkout(title: String, date: Date) {
        let session = WorkoutSession(date: date)
        let item = TimelineItem(title: title, startDate: date, endDate: date.addingTimeInterval(3600), type: .workout, workoutSession: session)
        context.insert(session)
        context.insert(item)
        items.append(item)
    }

    func addPersonalEvent(title: String, startDate: Date, endDate: Date) {
        let item = TimelineItem(title: title, startDate: startDate, endDate: endDate, type: .personal)
        context.insert(item)
        items.append(item)
    }
}
