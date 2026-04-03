import SwiftUI

struct TimelineItemView: View {
    let item: TimelineItem

    var body: some View {
        Text(item.title)
            .font(.caption2)
            .padding(4)
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(6)
    }

    private var color: Color {
        switch TimelineItemMapper.type(for: item) {
        case .workout: return .blue
        case .personal: return .green
        case .externalCalendar: return .orange
        }
    }
}
