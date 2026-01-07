//
//  DayCellView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

struct DayCellView: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(dayName)
                .font(.caption)

            Text(dayNumber)
                .font(.headline)
                .frame(width: 36, height: 36)
                .background(background)
                .foregroundColor(isSelected || isToday ? .white : .primary)
                .clipShape(Circle())
        }
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EE"
        return formatter.string(from: date).capitalized
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private var background: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .gray
        } else {
            return .clear
        }
    }
}
