import SwiftUI

struct DayColumnView: View {
    private let rows: [WeekViewModel.DayColumnRow]

    init(rows: [WeekViewModel.DayColumnRow]) {
        self.rows = rows
    }

    var body: some View {
        VStack(spacing: 4) {
            ForEach(rows) { row in
                HStack(spacing: 2) {
                    ForEach(row.items, id: \.item.id) { displayItem in
                        NavigationLink {
                            Text(displayItem.item.title)
                                .padding()
                        } label: {
                            EventView(
                                title: displayItem.item.title,
                                backgroundColor: displayItem.color.swiftUIColor
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .frame(height: 60)
                .overlay(
                    Text(row.timeLabel)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.leading, 2),
                    alignment: .leading
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}
