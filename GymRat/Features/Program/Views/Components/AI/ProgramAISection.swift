import SwiftUI

struct ProgramAISection: View {
    let onEdit: () -> Void

    var body: some View {
        Section("ai_section") {
            Button {
                onEdit()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ai_edit_button")
                        Text("ai_edit_button_subtitle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("aiEditButton")
        }
    }
}
