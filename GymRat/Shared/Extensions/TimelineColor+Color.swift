import SwiftUI

extension TimelineColor {
    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
            .opacity(opacity)
    }
}
