//
//  WeekCalendarView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

struct WeekCalendarView: View {

    @StateObject private var viewModel = CalendarViewModel()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.week) { day in
                    NavigationLink {
                        DayDetailView(date: day.date)
                    } label: {
                        DayCellView(
                            date: day.date,
                            isToday: viewModel.isToday(day.date),
                            isSelected: viewModel.isSelected(day.date)
                        )
                    }
                    .buttonStyle(.plain) // 🔥 УБИРАЕТ РАЗМЫТИЕ
                    .onTapGesture {
                        viewModel.select(day.date)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Календарь")
    }
}
