import SwiftUI

struct SetsBoxView: View {
    let title: String
    @Binding var setsText: String
    let focusedField: ProgramTableFocusField?
    @FocusState.Binding var focusedFieldBinding: ProgramTableFocusField?

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("-", text: $setsText)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .font(.headline)
                .bold()
                .focused($focusedFieldBinding, equals: focusedField)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .frame(width: 60, height: 60)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture { focusedFieldBinding = focusedField }
    }
}
