import SwiftUI

struct WeekView: View {

    let onSettingsTap: () -> Void

    @Environment(ThemeStore.self) private var themeStore
    @Environment(ProgramViewModel.self) private var programViewModel

    @State private var viewModel: WeekViewModel

    init(viewModel: WeekViewModel, onSettingsTap: @escaping () -> Void) {
        self.onSettingsTap = onSettingsTap
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
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
                selectedDate: viewModel.selectedDate,
                programViewModel: programViewModel
            ) {
                viewModel.showProgramPicker()
            }

        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("ok_button") {
                    NotificationCenter.default.post(name: .saveExerciseLogs, object: nil)
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

    // MARK: - Helpers
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
            set: { viewModel.selectDate($0) }
        )
    }
}
