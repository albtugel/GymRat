import SwiftUI

enum GymRatTheme: String, Codable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var accentColor: Color {
        didSet {
            saveAccentColor()
        }
    }
    
    @Published var selectedTheme: GymRatTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }

    init() {
        // Загружаем тему
        if let themeRaw = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = GymRatTheme(rawValue: themeRaw) {
            selectedTheme = theme
        } else {
            selectedTheme = .system
        }

        // Загружаем акцентный цвет
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
