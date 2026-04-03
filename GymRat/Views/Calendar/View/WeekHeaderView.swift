import SwiftUI

struct WeekHeaderView: View {

    @Binding var weekStartDate: Date
    @Binding var selectedDate: Date

    @Environment(ThemeManager.self) private var themeManager

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
                        if let day = calendar.date(byAdding: .day, value: index, to: weekStartDate) {
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

    // MARK: - Helpers
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        return cal
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = .current
        f.dateFormat = "LLLL yyyy"
        return f.string(from: weekStartDate)
    }

    private func dayNumber(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = .current
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private func weekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = calendar
        f.locale = .current
        f.dateFormat = "E"
        return f.string(from: date)
    }

    private func moveWeek(by value: Int) {
        guard let newStart = calendar.date(byAdding: .weekOfYear, value: value, to: weekStartDate) else { return }
        weekStartDate = newStart
        selectedDate = newStart
    }
}
