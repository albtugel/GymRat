import SwiftUI

struct WeekTimelineView: View {

    let onSettingsTap: () -> Void

    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var programManager: ProgramManager

    @State private var weekStartDate: Date
    @State private var showCalendar = false
    @State private var selectedDate: Date
    @State private var showProgramSheet = false

    init(onSettingsTap: @escaping () -> Void) {
        self.onSettingsTap = onSettingsTap
        let today = Date()
        _weekStartDate = State(initialValue: today.startOfWeek)
        _selectedDate = State(initialValue: today)
    }

    var body: some View {
        VStack(spacing: 2) {

            // --- Header ---
            HStack {
                Text("app_name")
                    .font(.largeTitle)
                    .bold()

                Spacer()

                Button {
                    onSettingsTap()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // --- Month header ---
            MonthHeaderView(selectedDate: selectedDate) {
                showCalendar = true
            }

            // --- Week Days + arrows ---
            WeekDaysArrowsView(
                weekStartDate: weekStartDate,
                selectedDate: $selectedDate,
                onChangeWeek: changeWeek
            )
            .padding(.bottom, 1)

            // --- Programs on selected day ---
            ProgramForSelectedDayView(selectedDate: selectedDate) {
                showProgramSheet = true
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
        .sheet(isPresented: $showCalendar) {
            CalendarSheetView(
                selectedDate: $selectedDate,
                weekStartDate: $weekStartDate,
                isPresented: $showCalendar
            )
        }
        .sheet(isPresented: $showProgramSheet) {
            ProgramSelectionView(selectedDate: $selectedDate)
                .environmentObject(programManager)
        }
    }

    // MARK: - Helpers
    private func changeWeek(by weeks: Int) {
        NotificationCenter.default.post(name: .saveExerciseLogs, object: nil)
        guard let newStart = AppCalendar.calendar.date(byAdding: .weekOfYear, value: weeks, to: weekStartDate) else { return }
        weekStartDate = newStart
        selectedDate = newStart
    }

}
