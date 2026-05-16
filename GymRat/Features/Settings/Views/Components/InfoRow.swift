import SwiftUI

struct InfoRow: View {
    private let titleKey: String
    private let valueText: String

    init(titleKey: String, valueText: String) {
        self.titleKey = titleKey
        self.valueText = valueText
    }


    var body: some View {
        HStack {
            Text(LocalizedStringKey(titleKey))
            Spacer()
            Text(valueText)
                .foregroundColor(.secondary)
        }
    }
}
