//
//  WeekTimelineView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI
import SwiftData

struct WeekTimelineView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: TimelineViewModel

    private let days: [Date]

    init() {
        _viewModel = StateObject(wrappedValue: TimelineViewModel(context: ModelContext.current!))
        let calendar = Calendar.current
        let today = Date()
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today)!
        let startOfWeek = weekInterval.start
        days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(days, id: \.self) { day in
                    DayColumnView(date: day, items: viewModel.items.filter {
                        Calendar.current.isDate($0.startDate, inSameDayAs: day)
                    })
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Неделя")
    }
}
