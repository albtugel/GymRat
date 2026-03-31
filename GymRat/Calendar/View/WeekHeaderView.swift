import SwiftUI

struct WeekHeaderView: View {

    @Binding var weekStartDate: Date
    @Binding var selectedDate: Date

    @EnvironmentObject private var themeManager: ThemeManager

    let onMonthTap: () -> Void

    var body: some View {
        VStack(spacing: 8) {

            Button(action: onMonthTap) {
                Text(monthTitle)
                    .font(.title2)
                    .bold()
            }

            HStack(spacing: 0) {

                // ⬅️ Назад
                Button {
                    moveWeek(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(themeManager.accentColor, lineWidth: 2)
                        )
                }
                .foregroundColor(themeManager.accentColor)

                Spacer()

                // Дни недели
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { index in
                        let day = calendar.date(byAdding: .day, value: index, to: weekStartDate)!

                        VStack(spacing: 4) {
                            Text(dayNumber(day))
                                .font(.headline)
                            Text(weekday(day))
                                .font(.caption)
                        }
                        .frame(width: 44, height: 44)
                        .foregroundColor(
                            calendar.isDateInToday(day) ? themeManager.accentColor :
                            .primary
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    calendar.isDate(day, inSameDayAs: selectedDate) ? themeManager.accentColor : .clear,
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
                            selectedDate = day
                        }
                    }
                }

                Spacer()

                // ➡️ Вперёд
                Button {
                    moveWeek(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(themeManager.accentColor, lineWidth: 2)
                        )
                }
                .foregroundColor(themeManager.accentColor)
            }
            .padding(.horizontal, 16)
        }
    }
}
