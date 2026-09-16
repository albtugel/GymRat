import SwiftUI

struct WeekView: View {

    let onSettingsTap: () -> Void

    @Environment(ThemeStore.self) private var themeStore
    @Environment(ProgramViewModel.self) private var programViewModel
    @Environment(\.viewModelFactory) private var viewModelFactory

    @State private var viewModel: WeekViewModel

    init(viewModel: WeekViewModel, onSettingsTap: @escaping () -> Void) {
        self.onSettingsTap = onSettingsTap
        _viewModel = State(initialValue: viewModel)
    }


    var body: some View {
        VStack(spacing: 2) {

            CalendarHeader(
                accentColor: themeStore.accentColor,
                onSettingsTap: onSettingsTap
            )

            MonthHeaderView(title: viewModel.monthTitle) {
                viewModel.showCalendar()
            }

            WeekSwitcher(viewModel: viewModel)
            .padding(.bottom, 1)

            DayProgramsView(
                viewModel: viewModelFactory.makeDayProgramsViewModel(
                    selectedDate: viewModel.selectedDate,
                    programViewModel: programViewModel
                ),
                selectedDate: viewModel.selectedDate,
                programViewModel: programViewModel
            ) {
                viewModel.showProgramPicker()
            }

        }
        .environment(viewModel.saveCoordinator)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("ok_button") {
                    Task { await viewModel.saveVisibleLogs() }
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil,
                                                    from: nil,
                                                    for: nil)
                }
            }
        }
        .sheet(isPresented: calendarPresented) {
            DateSheet(
                selectedDate: selectedDateBinding,
                onDone: viewModel.applyCalendarSelection
            )
        }
        .sheet(isPresented: programSheetPresented) {
            ProgramPickerView(selectedDate: selectedDateBinding)
                .environment(programViewModel)
        }
    }


    private var calendarPresented: Binding<Bool> {
        Binding(
            get: { viewModel.isCalendarPresented },
            set: { isPresented in
                isPresented ? viewModel.showCalendar() : viewModel.hideCalendar()
            }
        )
    }

    private var programSheetPresented: Binding<Bool> {
        Binding(
            get: { viewModel.isProgramSheetPresented },
            set: { isPresented in
                isPresented ? viewModel.showProgramPicker() : viewModel.hideProgramPicker()
            }
        )
    }

    private var selectedDateBinding: Binding<Date> {
        Binding(
            get: { viewModel.selectedDate },
            set: { date in Task { await viewModel.selectDate(date) } }
        )
    }
}
