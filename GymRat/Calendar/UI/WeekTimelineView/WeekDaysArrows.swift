import SwiftUI

struct WeekDaysArrowsView: View {
    let weekStartDate: Date
    @Binding var selectedDate: Date
    let onChangeWeek: (Int) -> Void

    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        GeometryReader { geo in
            let week = WeekTimelineHelpers.makeWeek(from: weekStartDate)
            let layout = WeekTimelineLayoutCalculator.calculate(totalWidth: geo.size.width)

            HStack(spacing: layout.daySpacing) {

                Button {
                    onChangeWeek(-1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: layout.arrowWidth, height: 50)
                }

                ForEach(week, id: \.self) { date in
                    Button {
                        NotificationCenter.default.post(name: .saveExerciseLogs, object: nil)
                        selectedDate = date
                    } label: {
                        VStack(spacing: 4) {
                            Text(date.dayShortName)
                                .font(.caption)
                                .lineLimit(1)
                                .fixedSize()
                            Text(date.dayNumberString)
                                .font(.headline)
                                .lineLimit(1)
                                .fixedSize()
                        }
                        .padding(8)
                        .frame(width: layout.dayWidth, height: 56)
                        .background(
                            selectedDate.isSameDay(as: date)
                                ? themeManager.accentColor.opacity(0.25)
                                : (date.isToday ? themeManager.accentColor.opacity(0.15) : Color.clear)
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    onChangeWeek(1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: layout.arrowWidth, height: 50)
                }
            }
            .frame(width: geo.size.width - 20)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 80)
    }
}
