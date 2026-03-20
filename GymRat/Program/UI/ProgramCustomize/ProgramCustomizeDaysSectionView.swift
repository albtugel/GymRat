import SwiftUI

struct ProgramCustomizeDaysSectionView: View {
    @Binding var selectedWeekdays: Set<ProgramWeekDay>

    var body: some View {
        Section("days_section") {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(ProgramWeekDay.allCases) { day in
                    let isSelected = selectedWeekdays.contains(day)
                    Button {
                        if isSelected {
                            selectedWeekdays.remove(day)
                        } else {
                            selectedWeekdays.insert(day)
                        }
                    } label: {
                        Text(day.localizedShortTitle)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
