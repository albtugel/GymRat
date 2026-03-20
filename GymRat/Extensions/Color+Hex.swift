import SwiftUI
import UIKit

extension Color {
    init?(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        value = value.hasPrefix("#") ? String(value.dropFirst()) : value
        guard value.count == 6, let hexValue = UInt64(value, radix: 16) else { return nil }
        let r = Double((hexValue >> 16) & 0xFF) / 255
        let g = Double((hexValue >> 8) & 0xFF) / 255
        let b = Double(hexValue & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
