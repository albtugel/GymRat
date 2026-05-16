import SwiftUI

struct WeekHeaderView: View {
    @Environment(ThemeStore.self) private var themeStore
    private let viewModel: WeekViewModel
    private let onMonthTap: () -> Void

    init(viewModel: WeekViewModel, onMonthTap: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onMonthTap = onMonthTap
    }


    var body: some View {
        VStack(spacing: 8) {
            MonthButton(
                title: viewModel.weekHeaderTitle,
                onTap: onMonthTap
            )

            WeekDaysRow(
                days: viewModel.weekDays,
                accentColor: themeStore.accentColor,
                onSelect: { viewModel.selectDate($0) },
                onChangeWeek: { viewModel.moveWeek(by: $0) }
            )
        }
    }
}
