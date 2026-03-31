import SwiftUI

struct MonthHeaderView: View {
    let selectedDate: Date
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Text(selectedDate.monthNameYear)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
