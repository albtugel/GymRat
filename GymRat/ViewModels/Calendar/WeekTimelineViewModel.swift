import CoreGraphics
import Foundation
import Observation

@Observable
@MainActor
final class WeekTimelineViewModel {

    struct WeekDayDisplay: Identifiable {
        let id: Date
        let date: Date
        let shortName: String
        let number: String
        let isSelected: Bool
        let isToday: Bool
    }

    struct WeekDaysLayout {
        let sidePadding: CGFloat
        let arrowWidth: CGFloat
        let dayWidth: CGFloat
        let daySpacing: CGFloat
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
        let formatter = DateFormatter()
        formatter.calendar = AppCalendar.calendar
        formatter.locale = .current
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: selectedDate).capitalized(with: .current)
    }

    var weekDays: [WeekDayDisplay] {
        let formatter = DateFormatter()
        formatter.calendar = AppCalendar.calendar
        formatter.locale = .current
        formatter.dateFormat = "EEE"

        let dayNumberFormatter = DateFormatter()
        dayNumberFormatter.calendar = AppCalendar.calendar
        dayNumberFormatter.locale = .current
        dayNumberFormatter.dateFormat = "d"

        return (0..<7).compactMap { offset in
            guard let date = AppCalendar.calendar.date(byAdding: .day, value: offset, to: weekStartDate) else {
                return nil
            }
            return WeekDayDisplay(
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

    func changeWeek(by value: Int) {
        notifySaveLogs()
        guard let newStart = AppCalendar.calendar.date(byAdding: .weekOfYear, value: value, to: weekStartDate) else {
            return
        }
        weekStartDate = newStart
        selectedDate = newStart
    }

    func presentCalendar() {
        isCalendarPresented = true
    }

    func dismissCalendar() {
        isCalendarPresented = false
    }

    func presentProgramSheet() {
        isProgramSheetPresented = true
    }

    func dismissProgramSheet() {
        isProgramSheetPresented = false
    }

    func applyCalendarSelection() {
        weekStartDate = selectedDate.startOfWeek
        isCalendarPresented = false
    }

    func layout(for totalWidth: CGFloat) -> WeekDaysLayout {
        let sidePadding: CGFloat = 0
        let arrowWidth: CGFloat = 44
        let daySpacing: CGFloat = 6
        let edgeSpacing: CGFloat = 4

        let dayWidth = max(
            (totalWidth - sidePadding * 2 - arrowWidth * 2 - edgeSpacing * 2 - daySpacing * 6) / 7,
            0
        )
        return WeekDaysLayout(
            sidePadding: sidePadding,
            arrowWidth: arrowWidth,
            dayWidth: dayWidth,
            daySpacing: daySpacing
        )
    }

    // MARK: - Helpers
    private func notifySaveLogs() {
        NotificationCenter.default.post(name: .saveExerciseLogs, object: nil)
    }
}
