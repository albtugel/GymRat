import SwiftUI

struct CalendarSheetView: View {
    @Binding var selectedDate: Date
    @Binding var weekStartDate: Date
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            DatePicker(
                "select_date_label",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .environment(\.calendar, AppCalendar.calendar)

            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done_button") {
                        weekStartDate = selectedDate.startOfWeek
                        isPresented = false
                    }
                }
            }
        }
    }
}
