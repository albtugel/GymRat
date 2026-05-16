import SwiftUI

struct AIAPIKeyStatusRow: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    init(
        title: LocalizedStringKey = "ai_api_key_saved",
        subtitle: LocalizedStringKey = "ai_api_key_saved_subtitle"
    ) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .imageScale(.large)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
