import SwiftUI

struct ProgramDaysView: View {
    private let viewModel: ProgramEditorViewModel

    init(viewModel: ProgramEditorViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        Section("days_section") {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(ProgramWeekday.allCases, id: \.self) { day in
                    let isSelected = viewModel.isWeekdaySelected(day)
                    Button {
                        viewModel.toggleWeekday(day)
                    } label: {
                        Text(ProgramWeekdayHelper.localizedShortTitle(for: day))
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
