import CoreGraphics
import Foundation
import Observation

@Observable
@MainActor
final class WeekViewModel {

    struct WeekdayDisplay: Identifiable {
        let id: Date
        let date: Date
        let shortName: String
        let number: String
        let isSelected: Bool
        let isToday: Bool
    }

    struct WeekdaysLayout {
        let sidePadding: CGFloat
        let arrowWidth: CGFloat
        let dayWidth: CGFloat
        let daySpacing: CGFloat
    }


    private(set) var weekStartDate: Date
    private(set) var selectedDate: Date
    private(set) var isCalendarPresented: Bool = false
    private(set) var isProgramSheetPresented: Bool = false
    let saveCoordinator: ExerciseLogSaveCoordinator

    init(initialDate: Date = Date(), saveCoordinator: ExerciseLogSaveCoordinator? = nil) {
        let start = initialDate.startOfWeek
        weekStartDate = start
        selectedDate = initialDate
        self.saveCoordinator = saveCoordinator ?? ExerciseLogSaveCoordinator()
    }


    var monthTitle: String {
        makeMonthTitle(for: selectedDate)
    }

    var weekHeaderTitle: String {
        makeMonthTitle(for: weekStartDate)
    }

    var weekDays: [WeekdayDisplay] {
        let formatter = makeDateFormatter(format: "EEE")
        let dayNumberFormatter = makeDateFormatter(format: "d")

        return (0..<7).compactMap { offset in
            guard let date = AppCalendar.calendar.date(byAdding: .day, value: offset, to: weekStartDate) else {
                return nil
            }
            return WeekdayDisplay(
                id: date,
                date: date,
                shortName: formatter.string(from: date),
                number: dayNumberFormatter.string(from: date),
                isSelected: date.isSameDay(as: selectedDate),
                isToday: date.isToday
            )
        }
    }


    /// Entries typed into the current day are written before the selection moves, so a row that is
    /// replaced or reloaded for the new day can never drop them.
    func selectDate(_ date: Date) async {
        await saveCoordinator.saveAll()
        selectedDate = date
    }

    func moveWeek(by value: Int) async {
        await saveCoordinator.saveAll()
        guard let newStart = AppCalendar.calendar.date(byAdding: .weekOfYear, value: value, to: weekStartDate) else {
            return
        }
        weekStartDate = newStart
        selectedDate = newStart
    }

    func showCalendar() {
        isCalendarPresented = true
    }

    func hideCalendar() {
        isCalendarPresented = false
    }

    func showProgramPicker() {
        isProgramSheetPresented = true
    }

    func hideProgramPicker() {
        isProgramSheetPresented = false
    }

    func applyCalendarSelection() {
        weekStartDate = selectedDate.startOfWeek
        isCalendarPresented = false
    }

    /// Used when the keyboard is dismissed from the toolbar, which may not move focus in a way every
    /// row notices.
    func saveVisibleLogs() async {
        await saveCoordinator.saveAll()
    }

    func layout(for totalWidth: CGFloat) -> WeekdaysLayout {
        let sidePadding: CGFloat = 0
        let arrowWidth: CGFloat = 44
        let daySpacing: CGFloat = 6
        let edgeSpacing: CGFloat = 4

        let dayWidth = max(
            (totalWidth - sidePadding * 2 - arrowWidth * 2 - edgeSpacing * 2 - daySpacing * 6) / 7,
            0
        )
        return WeekdaysLayout(
            sidePadding: sidePadding,
            arrowWidth: arrowWidth,
            dayWidth: dayWidth,
            daySpacing: daySpacing
        )
    }


    private func makeMonthTitle(for date: Date) -> String {
        makeDateFormatter(format: "LLLL yyyy")
            .string(from: date)
            .capitalized(with: .current)
    }

    private func makeDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = AppCalendar.calendar
        formatter.locale = .current
        formatter.dateFormat = format
        return formatter
    }
}
