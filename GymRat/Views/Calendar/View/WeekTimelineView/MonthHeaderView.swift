import SwiftUI

struct MonthHeaderView: View {
    let title: String
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Text(title)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
