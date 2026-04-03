import SwiftUI

struct WeekTimelineView: View {

    let onSettingsTap: () -> Void

    @Environment(ThemeManager.self) private var themeManager
    @Environment(ProgramViewModel.self) private var programViewModel

    @State private var viewModel: WeekTimelineViewModel

    init(viewModel: WeekTimelineViewModel, onSettingsTap: @escaping () -> Void) {
        self.onSettingsTap = onSettingsTap
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 2) {

            WeekTimelineHeaderView(
                accentColor: themeManager.accentColor,
                onSettingsTap: onSettingsTap
            )

            MonthHeaderView(title: viewModel.monthTitle) {
                viewModel.presentCalendar()
            }

            WeekDaysArrowsView(viewModel: viewModel)
            .padding(.bottom, 1)

            ProgramForSelectedDayView(
                selectedDate: viewModel.selectedDate,
                programViewModel: programViewModel
            ) {
                viewModel.presentProgramSheet()
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
            CalendarSheetView(
                selectedDate: selectedDateBinding,
                onDone: viewModel.applyCalendarSelection
            )
        }
        .sheet(isPresented: programSheetPresented) {
            ProgramSelectionView(selectedDate: selectedDateBinding)
                .environment(programViewModel)
        }
    }

    // MARK: - Helpers
    private var calendarPresented: Binding<Bool> {
        Binding(
            get: { viewModel.isCalendarPresented },
            set: { isPresented in
                isPresented ? viewModel.presentCalendar() : viewModel.dismissCalendar()
            }
        )
    }

    private var programSheetPresented: Binding<Bool> {
        Binding(
            get: { viewModel.isProgramSheetPresented },
            set: { isPresented in
                isPresented ? viewModel.presentProgramSheet() : viewModel.dismissProgramSheet()
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
