import SwiftUI

struct WeekHeaderView: View {
    @Environment(ThemeManager.self) private var themeManager
    private let viewModel: WeekTimelineViewModel
    private let onMonthTap: () -> Void

    init(viewModel: WeekTimelineViewModel, onMonthTap: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onMonthTap = onMonthTap
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            WeekHeaderMonthButtonView(
                title: viewModel.weekHeaderTitle,
                onTap: onMonthTap
            )

            WeekHeaderDaysRowView(
                days: viewModel.weekDays,
                accentColor: themeManager.accentColor,
                onSelect: { viewModel.selectDate($0) },
                onChangeWeek: { viewModel.changeWeek(by: $0) }
            )
        }
    }
}
