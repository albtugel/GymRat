//
//  DayColumnView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

struct DayColumnView: View {
    let date: Date
    let items: [TimelineItem]

    var body: some View {
        ZStack(alignment: .top) {
            TimeGridView()
            ForEach(items) { item in
                NavigationLink {
                    if let session = item.workoutSession {
                        WorkoutDetailView(session: session)
                    } else {
                        Text(item.title)
                            .padding()
                    }
                } label: {
                    TimelineItemView(item: item)
                }
                .buttonStyle(.plain)
                .offset(y: yOffset(for: item.startDate))
                .frame(height: height(for: item))
            }
        }
        .frame(width: 120)
    }
}
