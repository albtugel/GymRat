import SwiftUI

struct StatBoxView: View {
    @Binding var text: String
    let placeholder: String
    let isAccent: Bool
    let keyboard: UIKeyboardType
    let font: Font
    let editable: Bool
    let focusedField: ProgramTableFocusField?
    @FocusState.Binding var focusedFieldBinding: ProgramTableFocusField?
    @Environment(ThemeManager.self) private var themeManager

    let boxWidth: CGFloat
    let boxHeight: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isAccent ? themeManager.accentColor : Color.secondary, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))

            if editable {
                TextField(placeholder, text: $text)
                    .multilineTextAlignment(.center)
                    .keyboardType(keyboard)
                    .foregroundColor(isAccent ? themeManager.accentColor : .primary)
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
