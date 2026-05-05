import SwiftUI

struct WeekDaysRow: View {
    private let days: [WeekViewModel.WeekdayDisplay]
    private let accentColor: Color
    private let onSelect: (Date) -> Void
    private let onChangeWeek: (Int) -> Void

    init(
        days: [WeekViewModel.WeekdayDisplay],
        accentColor: Color,
        onSelect: @escaping (Date) -> Void,
        onChangeWeek: @escaping (Int) -> Void
    ) {
        self.days = days
        self.accentColor = accentColor
        self.onSelect = onSelect
        self.onChangeWeek = onChangeWeek
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            WeekArrowButton(
                systemName: "chevron.left",
                accentColor: accentColor,
                onTap: { onChangeWeek(-1) }
            )

            Spacer()

            HStack(spacing: 6) {
                ForEach(days) { day in
                    WeekDayCell(
                        day: day,
                        accentColor: accentColor,
                        onSelect: onSelect
                    )
                }
            }

            Spacer()

            WeekArrowButton(
                systemName: "chevron.right",
                accentColor: accentColor,
                onTap: { onChangeWeek(1) }
            )
        }
        .padding(.horizontal, 16)
    }
}
