import SwiftUI

struct SetRowValueField: View {
    @Binding private var text: String
    private let placeholder: String
    private let isAccent: Bool
    private let keyboard: UIKeyboardType
    private let font: Font
    private let editable: Bool
    private let focusedField: ExerciseField?
    @FocusState.Binding private var focusedFieldBinding: ExerciseField?
    private let boxWidth: CGFloat

    init(
        text: Binding<String>,
        placeholder: String,
        isAccent: Bool,
        keyboard: UIKeyboardType,
        font: Font,
        editable: Bool,
        focusedField: ExerciseField?,
        focusedFieldBinding: FocusState<ExerciseField?>.Binding,
        boxWidth: CGFloat
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isAccent = isAccent
        self.keyboard = keyboard
        self.font = font
        self.editable = editable
        self.focusedField = focusedField
        self._focusedFieldBinding = focusedFieldBinding
        self.boxWidth = boxWidth
    }

    var body: some View {
        ValueField(
            text: $text,
            placeholder: placeholder,
            isAccent: isAccent,
            keyboard: keyboard,
            font: font,
            editable: editable,
            focusedField: focusedField,
            focusedFieldBinding: $focusedFieldBinding,
            boxWidth: boxWidth,
            boxHeight: 36
        )
    }
}
