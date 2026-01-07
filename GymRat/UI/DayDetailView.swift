//
//  DayDetailView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

struct DayDetailView: View {

    let date: Date

    var body: some View {
        VStack(spacing: 16) {
            Text(formattedDate)
                .font(.title)

            Text("Тренировки пока нет")
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("День")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        DayDetailView(date: Date())
    }
}
