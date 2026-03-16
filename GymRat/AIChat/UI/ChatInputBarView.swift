import SwiftUI

struct ChatInputBarView: View {
    @Binding var text: String
    let onSend: () -> Void
    @FocusState var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            TextField("message_placeholder", text: $text)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.send)
                .focused($isFocused)
                .onSubmit { onSend() }

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}
