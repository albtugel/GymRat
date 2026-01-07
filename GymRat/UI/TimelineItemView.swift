//
//  TimelineItemView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

struct TimelineItemView: View {
    let item: TimelineItem

    var body: some View {
        Text(item.title)
            .font(.caption2)
            .padding(4)
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(6)
    }

    private var color: Color {
        switch item.type {
        case .workout: return .blue
        case .personal: return .green
        case .externalCalendar: return .orange
        }
    }
}
