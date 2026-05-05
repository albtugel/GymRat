import SwiftUI

struct AddProgramButton: View {
    private let accentColor: Color
    private let onAddProgramTap: () -> Void

    init(accentColor: Color, onAddProgramTap: @escaping () -> Void) {
        self.accentColor = accentColor
        self.onAddProgramTap = onAddProgramTap
    }

    // MARK: - Body
    var body: some View {
        HStack {
            Spacer()
            Button {
                onAddProgramTap()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("add_program_button")
                }
                .foregroundColor(accentColor)
            }
            Spacer()
        }
    }
}
