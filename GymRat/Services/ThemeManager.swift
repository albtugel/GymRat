import Observation
import SwiftUI

@Observable
final class ThemeManager {
    var accentColor: Color {
        didSet {
            saveAccentColor()
        }
    }

    var selectedTheme: GymRatTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }

    init() {
        if let themeRaw = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = GymRatTheme(rawValue: themeRaw) {
            selectedTheme = theme
        } else {
            selectedTheme = .system
        }

        if let colorData = UserDefaults.standard.data(forKey: "accentColor"),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            accentColor = Color(uiColor)
        } else {
            accentColor = .blue
        }
    }

    private func saveAccentColor() {
        let uiColor = UIColor(accentColor)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: "accentColor")
        }
    }
}
