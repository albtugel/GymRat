import SwiftUI

struct WeekHeaderMonthButtonView: View {
    private let title: String
    private let onTap: () -> Void

    init(title: String, onTap: @escaping () -> Void) {
        self.title = title
        self.onTap = onTap
    }

    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.title2)
                .bold()
        }
    }
}
