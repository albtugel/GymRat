import SwiftUI

struct ValueField: View {
    @Binding var text: String
    let placeholder: String
    let isAccent: Bool
    let keyboard: UIKeyboardType
    let font: Font
    let editable: Bool
    let focusedField: ExerciseField?
    @FocusState.Binding var focusedFieldBinding: ExerciseField?
    @Environment(ThemeStore.self) private var themeStore

    let boxWidth: CGFloat
    let boxHeight: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isAccent ? themeStore.accentColor : Color.secondary, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))

            if editable {
                TextField(placeholder, text: $text)
                    .multilineTextAlignment(.center)
                    .keyboardType(keyboard)
                    .foregroundColor(isAccent ? themeStore.accentColor : .primary)
                    .font(font)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .focused($focusedFieldBinding, equals: focusedField)
            } else {
                let value = text.isEmpty ? placeholder : text
                Text(value)
                    .foregroundColor(.primary)
                    .font(font)
            }
        }
        .frame(width: boxWidth, height: boxHeight)
        .contentShape(Rectangle())
    }
}
