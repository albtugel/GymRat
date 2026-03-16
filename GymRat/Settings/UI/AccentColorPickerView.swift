import SwiftUI

struct AccentColorPickerView: View {
    @Binding var selectedColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("accent_color")
                .font(.headline)

            ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}
