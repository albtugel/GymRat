import SwiftUI

struct SettingsInfoRowView: View {
    private let titleKey: String
    private let valueText: String

    init(titleKey: String, valueText: String) {
        self.titleKey = titleKey
        self.valueText = valueText
    }

    // MARK: - Body
    var body: some View {
        HStack {
            Text(LocalizedStringKey(titleKey))
            Spacer()
            Text(valueText)
                .foregroundColor(.secondary)
        }
    }
}
