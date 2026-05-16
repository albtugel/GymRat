import SwiftUI

struct WeekDayCell: View {
    private let day: WeekViewModel.WeekdayDisplay
    private let accentColor: Color
    private let onSelect: (Date) -> Void

    init(
        day: WeekViewModel.WeekdayDisplay,
        accentColor: Color,
        onSelect: @escaping (Date) -> Void
    ) {
        self.day = day
        self.accentColor = accentColor
        self.onSelect = onSelect
    }


    var body: some View {
        VStack(spacing: 4) {
            Text(day.number)
                .font(.headline)
            Text(day.shortName)
                .font(.caption)
        }
        .frame(width: 44, height: 44)
        .foregroundColor(day.isToday ? accentColor : .primary)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(day.isSelected ? accentColor : .clear, lineWidth: 2)
        )
        .onTapGesture { onSelect(day.date) }
    }
}
