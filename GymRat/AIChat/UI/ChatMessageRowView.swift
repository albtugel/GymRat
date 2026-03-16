import SwiftUI

struct ChatMessageRowView: View {
    let message: ChatMessage
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 40)
                Text(message.text)
                    .padding(10)
                    .background(themeManager.accentColor.opacity(0.15))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            } else {
                Text(message.text)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}
