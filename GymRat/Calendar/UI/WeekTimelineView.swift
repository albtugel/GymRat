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
        VStack(spacing: 16) {

            HStack {
                Text("GymRat")
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

            // Месяц сверху (по центру)
            monthHeaderView

            // Дни недели + стрелки
            weekDaysWithArrowsView

            // Программа на выбранный день
            dayProgramView

            Button {
                showProgramSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add the program")
                }
                .foregroundColor(themeManager.accentColor)
            }

            Spacer()
        }
        .sheet(isPresented: $showCalendar) {
            calendarSheet
        }
        .sheet(isPresented: $showProgramSheet) {
            ProgramSelectionView(selectedDate: $selectedDate)
                .environmentObject(programManager)
        }
    }

    // MARK: - Month Header
    private var monthHeaderView: some View {
        Button {
            showCalendar = true
        } label: {
            Text(selectedDate.monthNameYear)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Week Days + arrows
    private var weekDaysWithArrowsView: some View {
        GeometryReader { geo in
            let week = makeWeek(from: weekStartDate)
            let layout = calculateLayout(totalWidth: geo.size.width)

            HStack(spacing: layout.daySpacing) {

                Button {
                    changeWeek(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: layout.arrowWidth, height: 50)
                }

                ForEach(week, id: \.self) { date in
                    Button {
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
                    changeWeek(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .bold))
                        .frame(width: layout.arrowWidth, height: 50)
                }
            }
            .frame(width: geo.size.width - 20) // <-- ВАЖНО: центрирует всю строку
            .frame(maxWidth: .infinity)
        }
        .frame(height: 80)
    }

    // MARK: - Program for selected day
    private var dayProgramView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let program = programManager.dayPrograms[selectedDate.startOfDay] {
                Text(program.name)
                    .font(.title3)
                    .bold()
            } else {
                Text("No program yet")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Calendar Sheet
    private var calendarSheet: some View {
        NavigationStack {
            DatePicker(
                "Select date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        weekStartDate = selectedDate.startOfWeek
                        showCalendar = false
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func makeWeek(from date: Date) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    private func changeWeek(by weeks: Int) {
        guard let newStart = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: weekStartDate) else { return }
        weekStartDate = newStart
        selectedDate = newStart
    }

    // MARK: - Layout Calculator
    private func calculateLayout(totalWidth: CGFloat) -> (sidePadding: CGFloat, arrowWidth: CGFloat, dayWidth: CGFloat, daySpacing: CGFloat) {
        let sidePadding: CGFloat = 0        // отступ от края экрана
        let arrowWidth: CGFloat = 44         // ширина стрелок
        let daySpacing: CGFloat = 6          // расстояние между днями
        let edgeSpacing: CGFloat = 4         // расстояние между стрелкой и ближайшим днём

        // вычисляем ширину ячейки
        let dayWidth = (totalWidth - sidePadding * 2 - arrowWidth * 2 - edgeSpacing * 2 - daySpacing * 6) / 7

        return (sidePadding, arrowWidth, dayWidth, daySpacing)
    }
}

// MARK: - Date helpers
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfWeek: Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: self)?.start ?? self
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    var dayShortName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    var dayNumberString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: self)
    }

    var monthNameYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
