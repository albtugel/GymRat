import SwiftUI

struct ProgramCustomizeDaysSectionView: View {
    private let viewModel: ProgramCustomizeViewModel

    init(viewModel: ProgramCustomizeViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        Section("days_section") {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(ProgramWeekDay.allCases, id: \.self) { day in
                    let isSelected = viewModel.isWeekdaySelected(day)
                    Button {
                        viewModel.toggleWeekday(day)
                    } label: {
                        Text(ProgramWeekDayHelper.localizedShortTitle(for: day))
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
