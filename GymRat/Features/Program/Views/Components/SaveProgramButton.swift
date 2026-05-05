import SwiftUI

struct SaveProgramButton: View {
    private let accentColor: Color
    private let onSave: () -> Void

    init(accentColor: Color, onSave: @escaping () -> Void) {
        self.accentColor = accentColor
        self.onSave = onSave
    }

    // MARK: - Body
    var body: some View {
        Button {
            onSave()
        } label: {
            Text("save_button")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .font(.headline)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(accentColor)
                )
        }
        .contentShape(Rectangle())
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
