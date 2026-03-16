import SwiftUI

struct ProgramCustomizeDaysSectionView: View {
    @Binding var selectedWeekdays: Set<ProgramWeekDay>

    var body: some View {
        Section("days_section") {
            ForEach(ProgramWeekDay.allCases) { day in
                HStack {
                    Text(day.localizedTitle)
                    Spacer()
                    if selectedWeekdays.contains(day) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedWeekdays.contains(day) {
                        selectedWeekdays.remove(day)
                    } else {
                        selectedWeekdays.insert(day)
                    }
                }
            }
        }
    }
}
