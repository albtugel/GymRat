import SwiftUI

struct WeekDaysArrowsView: View {
    private let viewModel: WeekTimelineViewModel

    @Environment(ThemeManager.self) private var themeManager

    init(viewModel: WeekTimelineViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geo in
            let layout = viewModel.layout(for: geo.size.width)

            HStack(spacing: layout.daySpacing) {

                Button {
                    viewModel.changeWeek(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: layout.arrowWidth, height: 50)
                }

                ForEach(viewModel.weekDays) { day in
                    Button {
                        viewModel.selectDate(day.date)
                    } label: {
                        VStack(spacing: 4) {
                            Text(day.shortName)
                                .font(.caption)
                                .lineLimit(1)
                                .fixedSize()
                            Text(day.number)
                                .font(.headline)
                                .lineLimit(1)
                                .fixedSize()
                        }
                        .padding(8)
                        .frame(width: layout.dayWidth, height: 56)
                        .background(
                            day.isSelected
                                ? themeManager.accentColor.opacity(0.25)
                                : (day.isToday ? themeManager.accentColor.opacity(0.15) : Color.clear)
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    viewModel.changeWeek(by: 1)
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
