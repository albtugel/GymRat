import SwiftUI

struct TimeGridView: View {
    let hourHeight: CGFloat
    let hourLabels: [String]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(hourLabels.enumerated()), id: \.offset) { _, label in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: hourHeight)
                    .overlay(
                        Text(label)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.leading, 2),
                        alignment: .topLeading
                    )
            }
        }
    }
}
