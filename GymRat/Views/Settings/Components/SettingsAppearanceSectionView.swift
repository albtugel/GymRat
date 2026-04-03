import SwiftUI

struct SettingsAppearanceSectionView: View {
    @Binding private var selectedTheme: GymRatTheme
    @Binding private var accentColor: Color

    init(
        selectedTheme: Binding<GymRatTheme>,
        accentColor: Binding<Color>
    ) {
        self._selectedTheme = selectedTheme
        self._accentColor = accentColor
    }

    // MARK: - Body
    var body: some View {
        Section("appearance_section") {
            ThemeToggleView(selectedTheme: $selectedTheme)
            AccentColorPickerView(selectedColor: $accentColor)
        }
    }
}
