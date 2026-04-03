import SwiftUI

struct TimeGridView: View {
    let hourHeight: CGFloat
    let minHour: Int
    let maxHour: Int

    var body: some View {
        VStack(spacing: 0) {
            ForEach(minHour...maxHour, id: \.self) { hour in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: hourHeight)
                    .overlay(
                        Text("\(hour):00")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.leading, 2),
                        alignment: .topLeading
                    )
            }
        }
    }
}
