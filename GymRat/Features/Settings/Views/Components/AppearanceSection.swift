import SwiftUI

struct AppearanceSection: View {
    @Binding private var selectedTheme: ThemeMode
    @Binding private var accentColor: Color

    init(
        selectedTheme: Binding<ThemeMode>,
        accentColor: Binding<Color>
    ) {
        self._selectedTheme = selectedTheme
        self._accentColor = accentColor
    }


    var body: some View {
        Section("appearance_section") {
            ThemeView(selectedTheme: $selectedTheme)
            AccentColorPickerView(selectedColor: $accentColor)
        }
    }
}
