import SwiftUI

struct LinkRow: View {
    private let titleKey: String
    private let valueKey: String?
    private let url: URL

    init(
        titleKey: String,
        valueKey: String?,
        url: URL
    ) {
        self.titleKey = titleKey
        self.valueKey = valueKey
        self.url = url
    }


    var body: some View {
        Link(destination: url) {
            HStack {
                Text(LocalizedStringKey(titleKey))
                Spacer()
                linkValue
            }
        }
    }


    private var linkValue: some View {
        Group {
            if let valueKey {
                Text(LocalizedStringKey(valueKey))
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.secondary)
            }
        }
    }
}
