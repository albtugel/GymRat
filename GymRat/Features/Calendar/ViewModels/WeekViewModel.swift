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

    struct DayColumnRow: Identifiable {
        let id: Date
        let timeLabel: String
        let items: [(item: Event, color: TimelineColor)]
    }

    // MARK: - State
    private(set) var weekStartDate: Date
    private(set) var selectedDate: Date
    private(set) var isCalendarPresented: Bool = false
    private(set) var isProgramSheetPresented: Bool = false

    init(initialDate: Date = Date()) {
        let start = initialDate.startOfWeek
        weekStartDate = start
        selectedDate = initialDate
    }

    // MARK: - Derived
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

    // MARK: - Intents
    func selectDate(_ date: Date) {
        notifySaveLogs()
        selectedDate = date
    }

    func moveWeek(by value: Int) {
        notifySaveLogs()
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

    func rows(items: [Event]) -> [DayColumnRow] {
        let times = items.flatMap { [$0.startDate, $0.endDate] }
        let uniqueTimes = Array(Set(times)).sorted()
        let formatter = makeDateFormatter(format: "HH:mm")
        return uniqueTimes.map { time in
            let rowItems = items.filter {
                AppCalendar.calendar.isDate($0.startDate, equalTo: time, toGranularity: .minute)
            }
            let displayItems = rowItems.map { item in
                (item: item, color: CalendarViewModel.makeItemColor(for: item))
            }
            return DayColumnRow(
                id: time,
                timeLabel: formatter.string(from: time),
                items: displayItems
            )
        }
    }

    func hourLabels(minHour: Int, maxHour: Int) -> [String] {
        guard minHour <= maxHour else {
            return []
        }
        return (minHour...maxHour).map { hour in
            "\(hour):00"
        }
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

    // MARK: - Helpers
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

    private func notifySaveLogs() {
        NotificationCenter.default.post(name: .saveExerciseLogs, object: nil)
    }
}
