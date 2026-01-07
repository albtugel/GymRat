import SwiftUI

struct WeekHeaderView: View {

    @Binding var currentWeekStart: Date
    @EnvironmentObject var themeManager: ThemeManager

    private let calendar = Calendar.current

    var body: some View {
        VStack {
            // Месяц по центру
            Text(monthString(for: currentWeekStart))
                .font(.title2)
                .bold()
                .padding(.bottom, 4)

            HStack {
                // Стрелка назад
                Button {
                    moveWeek(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(themeManager.accentColor) // ✅ убрали .color
                        .padding(.horizontal, 8)
                }

                Spacer()

                // Дни недели с числами
                HStack(spacing: 12) {
                    ForEach(0..<7) { index in
                        let day = calendar.date(byAdding: .day, value: index, to: currentWeekStart)!
                        VStack {
                            Text(dayNumber(for: day))
                                .font(.subheadline)
                                .bold()
                            Text(shortWeekday(for: day))
                                .font(.caption)
                        }
                        .frame(minWidth: 30)
                    }
                }

                Spacer()

                // Стрелка вперед
                Button {
                    moveWeek(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(themeManager.accentColor) // ✅ убрали .color
                        .padding(.horizontal, 8)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func shortWeekday(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    private func monthString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    private func moveWeek(by weeks: Int) {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: weeks, to: currentWeekStart) {
            currentWeekStart = newDate
        }
    }
}
